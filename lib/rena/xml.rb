# -*- coding: utf-8 -*-
#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

require 'rexml/document'
require 'stringio'
require 'rena/rdf'

module Rena
module XML

XMLLiteral_DATATYPE_URI =
  URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral").freeze

XMLNamespace = "http://www.w3.org/XML/1998/namespace"

# FIXME
def is_NCName(str)
  if /^\d/ =~ str or /[!"#\$%&'\(\)\*\+,\/:;<=>\?@\[\\\]\^{\|}\~]/u =~ str
    return false
  end

  if str.empty?
    return false
  end

  true
end
module_function :is_NCName


class Reader
  def initialize
    @model = nil
    @blank_nodes = {}
    @used_id = []
  end
  attr_accessor :model

  def read(io, params)
    base = params[:base]
    if base.nil? and io.respond_to?(:base_uri) # for open-uri
      base ||= io.base_uri
    end

    @warn = params[:warn]

    doc = REXML::Document.new(REXML::IOSource.new(io)) # XXX
    read_from_xml_document(doc, base)
    nil
  end

  def read_from_xml_document(doc, base = nil)
    if base.nil?
      base = URI.parse("")
    elsif not base.is_a?(URI)
      base = URI.parse(base)
    end
    parse_doc(doc, base)
    nil
  end

  private

  def update_base(old_base, e)
    if v = e.attributes["xml:base"]
      base = old_base + v
      # xmlbase/test013.rdf
      # With an xml:base with fragment the fragment is ignored.
      base.fragment = nil
      base
    else
      old_base
    end
  end

  def update_lang(old_lang, e)
    if v = e.attributes["xml:lang"]
      if v.empty?
        nil
      else
        v
      end
    else
      old_lang
    end
  end

  def warn(msg)    
    @warn[msg] if @warn
    nil
  end

  def parse_doc(doc, base = URI.parse(""))
    root = doc.root
    if root
      if root.namespace == RDF::Namespace and root.name == 'RDF'
        parse_rdf(root, base)
      else
        parse_nodeElement(root, base) # XXX
      end
    end
  end

  def parse_rdf(rdf, base, lang = nil)
    base = update_base(base, rdf)
    lang = update_lang(lang, rdf)
    parse_nodeElementList(rdf.elements, base, lang)
  end

  def parse_nodeElementList(elements, base, lang)
    elements.each{|e|
      parse_nodeElement(e, base, lang)
    }
  end

  def parse_nodeElement(e, base, lang = nil)
    base = update_base(base, e)
    lang = update_lang(lang, e)

    # FIXME: nodeElementURIs であることをチェック

    id     = get_attribute(e, "ID",     RDF::Namespace)
    nodeID = get_attribute(e, "nodeID", RDF::Namespace)
    about  = get_attribute(e, "about",  RDF::Namespace)

    if [id, nodeID, about].compact.size > 1
      raise LoadError.new # FIXME
    end

    if id
      subject = parse_idAttr(id, base)
    elsif nodeID
      subject = parse_nodeIdAttr(nodeID)
    elsif about
      subject = @model.create_resource(base + about.value)
    else
      subject = @model.create_resource
    end

    # nodeElementURIs
    if e.namespace == RDF::Namespace
      if ["RDF","ID","about","parseType","resource","nodeID","datatype"].member?(e.local_name) or # coreSyntaxTerms
          "li" == e.local_name or
          ["aboutEach", "aboutEachPrefix", "bagID"].member?(e.local_name) # oldTerms
        raise LoadError.new # FIXME
      elsif e.local_name != "Description"
        warn("Illegal or unusual use of names from the RDF namespace: " + e.expanded_name)
      end
    end

    unless e.namespace == RDF::Namespace and e.local_name == "Description"
      uri = URI.parse(e.namespace + e.local_name)
      subject.add_property(RDF::Type, @model.create_resource(uri))
    end

    e.attributes.each_attribute{|attr|
      if predicate = parse_propertyAttr(attr)
        if predicate == RDF::Type
          subject.add_property(predicate,
                               @model.create_resource(URI.parse(attr.value)))
        else
          subject.add_property(predicate,
                               PlainLiteral.new(attr.value, lang))
        end
      end
    }

    parse_propertyEltList(subject, e.elements, base, lang)

    subject
  end

  def parse_propertyEltList(subject, elements, base, lang)
    li_counter = 0

    elements.each{|e|
      # propertyElt
      new_base = update_base(base, e)
      new_lang = update_lang(lang, e)

      # FIXME
      if e.namespace == RDF::Namespace
        if ["RDF","ID","about","parseType","resource","nodeID","datatype","Description","aboutEach","aboutEachPrefix","bagID"].member?(e.local_name)
          raise LoadError.new
        elsif e.local_name != "li"
          warn("Illegal or unusual use of names from the RDF namespace: " + e.expanded_name)
        end
      end

      if e.namespace==RDF::Namespace and e.local_name == "li"
        # List Expansion Rules
        predicate = URI.parse(RDF::Namespace + "_#{li_counter+=1}")
      else
        predicate = URI.parse(e.namespace + e.local_name)
      end

      parseType = get_attribute(e, "parseType", RDF::Namespace)

      if parseType
        # FIXME: rdf:ID以外のアトリビュートは全部エラーに
        if get_attribute(e, "resource", RDF::Namespace)
          raise LoadError.new("specifying an rdf:parseType of \"#{parseType.value}\" and an rdf:resource attribute at the same time is an error.")
        end

        case parseType.value
        when "Resource"
          object = parse_parseTypeResourcePropertyElt(e, new_base, new_lang)
        when "Collection"
          object = parse_parseTypeCollectionPropertyElt(e, new_base, new_lang)
        when "Literal"
          e.attributes.each_attribute{|attr|
            # rdfms-empty-property-elements/error003.rdf
            raise LoadError.new if parse_propertyAttr(attr)
          }
          object = parse_parseTypeLiteralPropertyElt(e, new_base, new_lang)
        else
          object = parse_parseTypeOtherPropertyElt(e, new_base, new_lang)
        end
      elsif e.elements.size == 1 # FIXME
        object = parse_resourcePropertyElt(e, new_base, new_lang)
      elsif e.children.any?{|c| c.is_a? REXML::Text }
        object = parse_literalPropertyElt(e, new_base, new_lang)
      else
        object = parse_emptyPropertyElt(e, new_base, new_lang)
      end

      subject.add_property(predicate, object)

      if id = get_attribute(e, "ID", RDF::Namespace)
        parse_idAttr(id, new_base).
          add_property(RDF::Type, @model.create_resource(RDF::Statement)).
          add_property(RDF::Subject, subject).
          add_property(RDF::Predicate, @model.create_resource(predicate)).
          add_property(RDF::Object, object)
      end

      # XXX
      unless object.is_a?(Rena::Literal)
        e.attributes.each_attribute{|attr|
          if predicate2 = parse_propertyAttr(attr)
            subject2 = object
            # FIXME
            if predicate == RDF::Type
              object2 = @model.create_resource(URI.parse(attr.value))
            else
              object2 = PlainLiteral.new(attr.value, new_lang)
            end
            subject2.add_property(predicate2, object2)
          end
        }
      end
    }
  end

  def parse_parseTypeResourcePropertyElt(e, base, lang=nil)
    object = @model.create_resource
    parse_propertyEltList(object, e.elements, base, lang)
    object
  end

  def parse_parseTypeCollectionPropertyElt(e, base, lang=nil)
    items = e.elements.map{|e2| parse_nodeElement(e2, base, lang) }
    items.reverse.inject(@model.create_resource(RDF::Nil)){
      |result, item|
      @model.create_resource.
        add_property(RDF::First, item).
        add_property(RDF::Rest, result)
    }
  end

  def parse_parseTypeLiteralPropertyElt(e, base, lang=nil)
    io = StringIO.new
    c14n = ExecC14N.new(io)
    c14n.run(e)
    TypedLiteral.new(io.string, XMLLiteral_DATATYPE_URI)
  end

  def parse_parseTypeOtherPropertyElt(e, base, lang=nil)
    parse_parseTypeLiteralPropertyElt(e, base, lang)
  end

  def parse_resourcePropertyElt(e, base, lang=nil)
    # FIXME: rdf:ID以外のアトリビュートをエラーに
    parse_nodeElement(e.elements[1], base, lang)
  end

  def parse_literalPropertyElt(e, base, lang=nil)
    # FIXME: rdf:IDとrdf:datatype以外のアトリビュートをエラーに

    s = e.children.select{|c| c.is_a?(REXML::Text) }.map{|c| c.value }.join('')
    if attr_type = get_attribute(e, "datatype", RDF::Namespace)
      TypedLiteral.new(s, base + attr_type.value)
    else
      PlainLiteral.new(s, lang)
    end
  end

  def parse_emptyPropertyElt(e, base, lang=nil)
    # XXX: If there are no attributes or only the optional rdf:ID attribute i.
    is_literal = true
    e.attributes.each_attribute{|attr|
      if parse_propertyAttr(attr)
        is_literal = false
        break
      end

      if attr.namespace == RDF::Namespace and attr.local_name == 'ID'
        next
      elsif /^xml/ =~ attr.prefix or attr.namespace == XMLNamespace
        next
      else
        is_literal = false
        break
      end
    }

    if is_literal
      PlainLiteral.new('', lang)
    else
      resource = get_attribute(e, "resource", RDF::Namespace)
      nodeID   = get_attribute(e, "nodeID", RDF::Namespace)

      # rdfms-syntax-incomplete/error006.rdf
      if resource and nodeID
        raise LoadError.new("Cannot have rdf:nodeID and rdf:resource")
      end

      if resource
        @model.create_resource(base + resource.value)
      elsif nodeID
        parse_nodeIdAttr(nodeID)
      else
        @model.create_resource
      end
    end
  end

=begin
  CoreSyntaxTerms_local_name = [
    "RDF", "ID", "about", "parseType", "resource", "nodeID", "datatype"
  ]
  SyntaxTerms_local_name = CoreSyntaxTerms_local_name + [
    "Description", "li"
  ]
  OldTerms_local_name = ["aboutEach", "aboutEachPrefix", "bagID"]
=end

  def parse_propertyAttr(attr)
    if /^xml/i =~ attr.prefix
      nil
    elsif (attr.local_name==attr.expanded_name) and /^xml/i =~ attr.local_name # XXX
      nil
    else
      ns = attr.namespace
      return nil unless ns
      return nil if ns == XMLNamespace

      if ns==RDF::Namespace
        # oldTerms
        if ["aboutEach", "aboutEachPrefix", "bagID"].member?(attr.local_name)
          raise LoadError.new("rdf:aboutEach, rdf:aboutEachPrefix and rdf:bagID are obsoleted")
        end

        if ["RDF", "li", "Description"].member?(attr.local_name)
          raise LoadError.new
        end

        # coreSyntaxTerms - RDF
        if ["ID", "about", "parseType", "resource", "nodeID", "datatype"].member?(attr.local_name)
          return nil
        end

        warn("Illegal or unusual use of names from the RDF namespace: " + attr.expanded_name)
      end

      uri = URI.parse(ns + attr.local_name)
      uri.freeze
      uri
    end
  end

  def parse_idAttr(attr, base)
    unless XML.is_NCName(attr.value)
      raise LoadError.new("The value of rdf:ID (#{attr.value.inspect}) must match the XML Name production, (as modified by XML Namespaces). ")
    end

    # uri = base + ("#" + attr.value)
    uri = base.dup
    uri.fragment = attr.value
    uri.freeze

    if @used_id.member?(uri)
      raise LoadError.new("two elements cannot use the same ID")
    else
      @used_id.push uri
    end

    @model.create_resource(uri)
  end

  def parse_nodeIdAttr(attr)
    unless XML.is_NCName(attr.value)
      raise LoadError.new("The value of rdf:nodeID (#{attr.value.inspect}) must match the XML Name production, (as modified by XML Namespaces). ")
    end

    @blank_nodes[attr.value] ||= @model.create_resource
  end

  private

  # to avoid bugs of REXML::Element.
  def get_attribute(e, name, namespace)
    e.prefixes.each{|prefix|
      if e.namespace(prefix) == namespace
        return e.attributes.get_attribute(prefix + ':' + name)
      end
    }
    nil
  end


  # Exclusive XML Canonicalization
  class ExecC14N
    def initialize(output)
      @output = output
    end

    def run(e)
      e.children.each{|child| do_c14n(child, {}) }
    end

    private

    def do_c14n(node, ns_rendered)
      case node
      when REXML::Comment
        @output.print('<!--', node.string, '-->')
      when REXML::Text
        @output.print(escape_text(node.value))
      when REXML::Element
        do_c14n_element(node, ns_rendered)
      when REXML::Instruction
        @output.print('<?', node.target)
        unless node.content.empty?
          @output.print(' ', node.content)
        end
        @output.print('?>')
      end
    end

    def do_c14n_element(node, ns_rendered)
      ns_table   = []
      attr_table = []
      new_ns_rendered = ns_rendered.dup

      if node.prefix != '' and
          ns_rendered[node.prefix] != node.namespace
        ns = node.namespace
        ns_table.push [node.prefix, ns]
        new_ns_rendered[node.prefix] = ns
      end

      node.attributes.each_attribute{|attr|
        next if "xmlns"==attr.prefix or "xmlns"==attr.expanded_name

        if attr.prefix != '' and ns_rendered[attr.prefix] != attr.namespace
          ns = attr.namespace
          ns_table.push [attr.prefix, ns]
          new_ns_rendered[attr.prefix] = ns
        end
        attr_table.push attr
      }
      
      @output.print('<', node.fully_expanded_name)
      
      if node.prefix=='' and
          node.namespace!='' and ns_rendered[''] != node.namespace
        @output.print(' ', 'xmlns', '=', '"',
                      escape_attr_value(node.namespace),
                      '"')
        new_ns_rendered[''] = node.namespace
      end
      
      ns_table = ns_table.sort_by{|(prefix,namespace)| prefix }
      ns_table.each{|(prefix,namespace)|
        @output.print(' ', 'xmlns:', prefix, '=', '"',
                      escape_attr_value(namespace),
                      '"')
      }
      
      attr_table = attr_table.sort_by{|attr|
        [attr.prefix.empty? ? '' : attr.namespace, attr.local_name]
      }
      attr_table.each{|attr|
        @output.print(' ', attr.fully_expanded_name, '=', '"',
                     escape_attr_value(attr.value),
                     '"')
      }
      
      @output.print '>'
      
      node.children.each{|child|
        do_c14n(child, new_ns_rendered)
      }
      
      @output.print('</', node.fully_expanded_name, '>')
    end

    def escape_text(s)
      s = s.dup
      s.gsub!(/&/,  '&amp;')
      s.gsub!(/</,  '&lt;')
      s.gsub!(/>/,  '&gt;')
      s.gsub!(/\r/, '&#xD;')
      s
    end

    def escape_attr_value(s)
      s = s.dup
      s.gsub!(/&/,  '&amp;')
      s.gsub!(/</,  '&lt;')
      s.gsub!(/>/,  '&gt;')
      s.gsub!(/"/,  '&quot;')
      s.gsub!(/\t/, '&#x9;')
      s.gsub!(/\n/, '&#xA;')
      s.gsub!(/\r/, '&#xD;')      
      s
    end
  end # class ExecC14N

end # class Reader




class Writer
  def initialize
    @namespaces = Hash.new
    @namespaces["rdf"] = RDF::Namespace
    @ns_counter = 0

    @written = Set[]
    @blank_nodes_to_element = Hash.new
    @blank_counter = 0

    @root = nil

    @rss = false
  end
  attr_reader :namespaces
  attr_accessor :rss

  private

  def have_property?(resource)
    resource.each_property{ return true }
    false
  end

  def force_toplevel?(prop, object)
    if @rss
      prop = prop.to_s
      if prop == "http://purl.org/rss/1.0/items"
        false
      #elsif %r!http://www.w3.org/1999/02/22-rdf-syntax-ns#_\d+! =~ prop
      #  true
      else
      #  false
        true
      end
    else
      true
    end
  end

  def write_nodeElementList(rdf)
    first = true
    parent = rdf
    f = lambda{|resource|
      if first
        first = false
        parent << REXML::Text.new("\n")
      end
      write_nodeElement(parent, resource)
    }

    @model.each_resource{|resource|
      next if @written.member?(resource)
      next unless have_property?(resource)

      flag = false
      @model.each_statement{|stmt|
        if stmt.object == resource
          flag = true 
          break
        end
      }
      next if flag

      f[resource]
    }

    @model.each_resource{|resource|
      next if @written.member?(resource)
      next unless have_property?(resource)
      f[resource]
    }    
  end

  def write_nodeElement(parent, resource)
    type  = nil
    ename = nil
    resource.get_property_values(RDF::Type).each{|t|
      begin
        ename = fold_uri(t.uri)
        type  = t
        true
      rescue
        false
      end
    }
    
    ename = fold_uri(RDF::Namespace + "Description") unless type
    e = REXML::Element.new(ename)
 
    parent << REXML::Text.new("\n")
    parent << e
    parent << REXML::Text.new("\n")
    if resource.uri
      e.add_attribute(fold_uri(RDF::Namespace + "about"), resource.uri.to_s)
    else
      @blank_nodes_to_element[resource] = e
    end

    unless @written.member?(resource)
      @written << resource
      write_propertyEltList(e, resource, type)
    end

    e
  end

  def write_propertyEltList(parent, resource, type = nil)
    first = true
    create_element = lambda{|ename|
      if first
        first = false
        parent << REXML::Text.new("\n")
      end        
      e = REXML::Element.new(ename)
      parent << e
      parent << REXML::Text.new("\n")
      e
    }

    list_used = Set[]
    i = 1
    loop{
      prop = URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#_#{i.to_s}")
      if object = resource.get_property(prop)
        e = create_element["rdf:li"]
        write_propertyElt(e, prop, object)
        list_used << [prop,object]
        i += 1
      else
        break;
      end
    }

    resource.each_property{|prop, object|
      next if prop == RDF::Type and object == type
      next if list_used.include?([prop,object])

      if object.is_a?(Rena::PlainLiteral) and !object.lang and
          (ename = fold_uri(prop,false)) and parent.attribute(ename).nil? and
          not @rss
        parent.add_attribute(ename, object.to_s.dup)
      else
        e = create_element[fold_uri(prop)]
        write_propertyElt(e, prop, object)
      end
    }
  end

  def write_propertyElt(e,prop,object)
      if object.is_a?(Rena::PlainLiteral)
        e << REXML::Text.new(object.to_s.dup, true)
        e.add_attribute("xml:lang", object.lang.to_s.dup) if object.lang
      elsif object.is_a?(Rena::TypedLiteral)
        if XMLLiteral_DATATYPE_URI == object.type
          tmp = REXML::Document.new('<dummy>' + object.to_s + '</dummy>')
          tmp.root.children.to_a.each{|child|
            e << child.remove
          }
          e.add_attribute(fold_uri(RDF::Namespace + "parseType"), 'Literal')
        elsif not object.to_s.empty?        
          e << REXML::Text.new(object.to_s.dup, true)
          e.add_attribute(fold_uri(RDF::Namespace + "datatype"),
                          object.type.to_s.dup)
        else
          raise SaveError.new("can't write empty TypedLiteral")
        end
      else
        if @written.member?(object)
          if object.uri
            e.add_attribute(fold_uri(RDF::Namespace + "resource"),
                            object.uri.to_s)
          else
            e.add_attribute(fold_uri(RDF::Namespace + "nodeID"),
                            blank_node_to_nodeID(object))
          end
        else
          if object.uri
            if have_property?(object)
              if force_toplevel?(prop, object)
                write_nodeElement(@root, object)
                e.add_attribute(fold_uri(RDF::Namespace + "resource"),
                                object.uri.to_s)
              else
                write_nodeElement(e, object)
              end
            else
              e.add_attribute(fold_uri(RDF::Namespace + "resource"),
                              object.uri.to_s)
            end
          else
            # XXX
            if have_property?(object) and force_toplevel?(prop, object)
              write_nodeElement(@root, object)
              e.add_attribute(fold_uri(RDF::Namespace + "nodeID"),
                              blank_node_to_nodeID(object))
            else
              write_nodeElement(e, object)
            end
          end
          @written << object
        end
      end
  end

  def fold_uri(uri, allow_empty_prefix = true)
    uri_s = uri.to_s
    result = nil

    @namespaces.each_pair{|prefix, namespace|
      if /\A#{Regexp.quote(namespace)}(.*)\Z/u =~ uri_s
        tmp = $1
        next unless XML.is_NCName(tmp)

        if prefix.empty?
          return tmp if allow_empty_prefix
        else
          return prefix + ":" + tmp
        end
      end
    }

    uri = uri.dup
    if s = uri.fragment
      raise SaveError.new("#{s.inspect} doesn't match the XML Name production (as modified by XML Namespaces). ") unless XML.is_NCName(s)
      uri.fragment = ''
    elsif s = uri.query
      raise SaveError.new("#{s.inspect} doesn't match the XML Name production (as modified by XML Namespaces). ") unless XML.is_NCName(s)
      uri.query = ''
    elsif path = uri.path
      %r!\A(.*/)([^/]+)\Z! =~ path
      uri.path, s = $1, $2
      raise SaveError.new("#{s.inspect} doesn't match the XML Name production (as modified by XML Namespaces). ") unless XML.is_NCName(s)
    else
      # FIXME
      raise SaveError.new("FIXME: no namespace match against #{uri}")
    end

    loop {
      prefix = "ns" + @ns_counter.to_s
      @ns_counter = @ns_counter.succ
      unless @namespaces.has_key?(prefix)
        uri = uri.to_s
        @namespaces[prefix] = uri
        @root.add_namespace(prefix, uri)
        return prefix + ":" + s
      end
    }
  end

  def blank_node_to_nodeID(resource)
    e = @blank_nodes_to_element[resource]

    # XXX
=begin
    unless e
      e = REXML::Element.new(fold_uri(RDF::Namespace + "Description"))
      @root << e
    end
=end

    if nodeID = e.attribute("nodeID", RDF::Namespace)
      nodeID.value
    else
      v = "blank" + @blank_counter.to_s
      e.add_attribute(fold_uri(RDF::Namespace + "nodeID"), v)
      @blank_counter = @blank_counter.succ
      v
    end
  end

  public

  def model2rdfxml(m)
    doc = REXML::Document.new()
    doc << REXML::Text.new("\n")

    @root = REXML::Element.new(fold_uri(RDF::Namespace + "RDF"))
    doc << @root

    namespaces.each_pair{|prefix, namespace|
      if prefix.empty?
        @root.add_namespace(namespace)
      else
        @root.add_namespace(prefix, namespace)
      end
    }

    @model = m
    write_nodeElementList(@root)

    doc
  end

  def write(io, m, params)
    doc = model2rdfxml(m)
    doc.write(REXML::Output.new(io, params[:charset] || 'utf-8'))
    nil
  end
end # class Writer


end # module XML
end # module Rena

