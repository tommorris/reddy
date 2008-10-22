require 'lib/rena'
require 'ruby-debug'
require 'xml'
include Rena

module Rena
  include LibXML
  class RdfXmlParser
    SYNTAX_BASE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    RDF_TYPE = SYNTAX_BASE + "type"
    RDF_DESCRIPTION = SYNTAX_BASE + "Description"

    attr_accessor :xml, :graph
    def initialize(xml_str, uri = nil)
      @excl = ["http://www.w3.org/1999/02/22-rdf-syntax-ns#resource",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#about",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#ID"]
      @uri = Addressable::URI.parse(uri).to_s unless uri.nil?
      @graph = Rena::Graph.new
      @xml = LibXML::XML::Parser.string(xml_str).parse
      @id_mapping = Hash.new
      root = @xml.root
      if is_rdf_root?(root)
        root.each_element {|el|
          parse_descriptions(el)
        }
      else
        root.each_element {|n|
          if is_rdf_root?(n)
            n.each_element {|el|
              parse_descriptions(el)
            }
          end
        }
      end
    end
  
    private
    def is_rdf_root? (node)
      if node.namespace_node.href == SYNTAX_BASE && node.name == "RDF"
        return true
      else
        return false
      end
    end
    
    def parse_descriptions(el, subject=nil)
      # subject
      subject = parse_subject(el) if subject.nil?
      # class
      unless el.name == "Description" && el.namespace_node.href == SYNTAX_BASE
        @graph.add_triple(subject, RDF_TYPE, url_helper(el.name, el.namespace_node.href, el.base))
      end

      # read each attribute that's not in SYNTAX_BASE
      el.attributes.each { |att|
        @graph.add_triple(subject, url_helper(att.name, att.ns.href, el.base), att.value) unless att.ns.href == SYNTAX_BASE
      }
      
      el.each_element {|child|
        predicate = url_helper(child.name, child.namespace_node.href, child.base)
        object = child.content
        if el.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID")
          @graph.add_triple(subject, predicate, forge_bnode_from_string(child.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID").value))
        elsif child.attributes.get_attribute_ns(SYNTAX_BASE, "resource")
          @graph.add_triple(subject, predicate, URIRef.new(base_helper(child.attributes.get_attribute_ns(SYNTAX_BASE, "resource").value, child.base).to_s))
        end
        child.each {|contents|
          if contents.text? and contents.content.strip.length != 0
            object = contents.content
            @graph.add_triple(subject, predicate, object)
          end
        }
        child.each_element {|cel|
          object = parse_subject(cel)
          if child.attributes.get_attribute_ns(SYNTAX_BASE, "parseType")
            case child.attributes.get_attribute_ns(SYNTAX_BASE, "parseType").value
            when "XMLLiteral"
              object = Literal.typed(cel.namespaced_to_s, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
              @graph.add_triple(subject, predicate, object)
            when "Literal"
              if smells_like_xml?(cel.namespaced_to_s)
                object = Literal.typed(cel.to_s, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
                @graph.add_triple(subject, predicate, object)
              else
                object = cel.to_s
                @graph.add_triple(subject, predicate, object)
              end
            when "Resource"
              object = BNode.new
              @graph.add_triple(subject, predicate, object)
              parse_descriptions(cel, resource)
            #when "Collection";
            end
          else
            @graph.add_triple(subject, predicate, object)
            parse_descriptions(cel)
          end
        }

        # reification
        if child.attributes.get_attribute_ns(SYNTAX_BASE, "ID")
          if id_check?(child.attributes.get_attribute_ns(SYNTAX_BASE, "ID").value)
            rsubject = url_helper("#" + child.attributes.get_attribute_ns(SYNTAX_BASE, "ID").value, child.base)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement"))
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#subject"), subject)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate"), predicate)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#object"), object)
          else
            raise
          end
        end
        
      }
      
    end
    
    private
    def fail_check(el)
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "aboutEach")
        raise Rena::AboutEachException
      end
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "aboutEachPrefix")
        raise Rena::AboutEachException
      end
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "bagID")
        raise "Bad BagID" unless el.attributes.get_attribute_ns(SYNTAX_BASE, "bagID").value =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
      end
    end
    
    def parse_subject(el)
      fail_check(el)
      
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "about")
        #debugger if el.attributes.get_attribute_ns(SYNTAX_BASE, "about").value =~ /artist$/
        return URIRef.new(base_helper(el.attributes.get_attribute_ns(SYNTAX_BASE, "about").value, el.base).to_s)
      elsif el.attributes.get_attribute_ns(SYNTAX_BASE, "ID")
        id = el.attributes.get_attribute_ns(SYNTAX_BASE, "ID")
        if id_check?(id.value)
          return url_helper("#" + id.value, "", el.base)
        else
          raise
        end
      elsif el.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID")
        return BNode.new(el.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID").value)
      else
        return BNode.new
      end
      subject = nil
      el.attributes.each_attribute do |att|
        uri = url_helper(att.namespace + att.name).to_s
        value = att.to_s
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#bagID"
          raise
          if name =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # TODO: do something intelligent with the bagID
          else
            raise
          end
        end
        
        if uri == SYNTAX_BASE + "#resource" || uri == SYNTAX_BASE + "#about" #specified resource
          subject = URIRef.new(base_helper(value, el.base))
        end
        
        if uri.to_s == SYNTAX_BASE + "#nodeID" #BNode with ID
          # we have a BNode with an identifier. First, we need to do syntax checking.
          if value =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # now we check to see if the graph has the value
            return forge_bnode_from_string(value)
          end
        end
      end
      
      return subject
    end
    
    def forge_bnode_from_string(value)
      if @graph.has_bnode_identifier?(value)
        # if so, pull it in - no need to recreate objects.
        subject = @graph.get_bnode_by_identifier(value)
      else
        # if not, create a new one.
        subject = BNode.new(value)
      end
      
      return subject
    end
    
    def id_check?(id)
      !(!(id =~ /^[a-zA-Z_]\w*$/))
    end
    
    def parse_object_atts (el)
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "resource")
        return URIRef.new(base_helper(el.attributes.get_attribute_ns(SYNTAX_BASE, "resource").value, el.base).to_s)
      end
    end
    


    def levels_to_root (el, num = 0)
      if el.parent == @xml.root
        return num
      else
        levels_to_root el.parent, num + 1
      end
    end

    protected

    def parse_element (element, subject = nil, resource = false)
      if subject == nil
        # figure out subject
        subject = self.get_uri_from_atts(element, true)
      end
      
      # type parsing
      if (resource == true or element.attributes.has_key? 'about')
        type = URIRef.new(element.namespace + element.name)
        unless type.to_s == RDF_TYPE
          @graph.add_triple(subject, RDF_DESCRIPTION, type)
        end
      end
      
      # attribute parsing
      element.attributes.each_attribute { |att|
        uri = att.namespace + att.name
        value = att.to_s
    
        unless @excl.member? uri
          @graph.add_triple(subject, uri, Literal.untyped(value))
        end
      }

      # element parsing
      element.each_element { |e|
        self.parse_resource_element e, subject
      }
    end
    
    def smells_like_xml?(str)
      !(!(str =~ /xmlns/))
    end
    
    def base_helper(uri, base = nil)
      uri = Addressable::URI.parse(uri)
      if uri.relative?
        if !base.nil?
          uri = Addressable::URI.parse(base)
        elsif !@uri.nil?
          uri = Addressable::URI.parse(@uri) + uri
        end
      end
      #debugger if @uri.to_s =~ /bbc\.co\.uk/      
      return uri.to_s
    end
    
    def url_helper(name, ns, base = nil)
      if ns != "" and !ns.nil?
        if ns.to_s.split("")[-1] == "#"
          a = Addressable::URI.parse(ns) + Addressable::URI.parse("#" + name)
        else
          a = Addressable::URI.parse(ns) + Addressable::URI.parse(name)
        end
      else
        a = Addressable::URI.parse(name)
      end
      if a.relative?
        a = base_helper(a.to_s, base)
      end
      
      return URIRef.new(a.to_s)
    end
    
  end
end
