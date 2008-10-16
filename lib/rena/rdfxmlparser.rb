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
      @uri = Addressable::URI.parse(uri) unless uri.nil?
      @graph = Rena::Graph.new
      @xml = LibXML::XML::Parser.string(xml_str).parse
      root = @xml.root
      if is_rdf_root?(root)
        parse_descriptions(root)
      else
        root.each {|n|
          if is_rdf_root?(n)
            parse_descriptions(n)
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
    
    private
    def fail_check(el)
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "aboutEach")
        raise Rena::AboutEachException
      end
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "aboutEachPrefix")
        raise Rena::AboutEachException
      end
    end
    
    def parse_subject(el)
      fail_check(el)
      
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "about")
        return URIRef.new(el.attributes.get_attribute_ns(SYNTAX_BASE, "about").value)
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
      element.attributes.each_attribute do |att|
        uri = att.namespace + att.name
        value = att.to_s
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#aboutEach"
          raise AboutEachException, "Failed as per RDFMS-AboutEach-Error001.rdf test from 2004 test suite"
        end
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#aboutEachPrefix"
          raise AboutEachException, "Failed as per RDFMS-AboutEach-Error002.rdf test from 2004 test suite"
        end
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#bagID"
          raise
          if name =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # TODO: do something intelligent with the bagID
          else
            raise
          end
        end
        
        if uri == resourceuri #specified resource
          element_uri = Addressable::URI.parse(value)
          if (element_uri.relative?)
            # we have an element with a relative URI
            if (element.base?)
              # the element has a base URI, use that to build the URI
              value = "##{value}" if (value[0..0].to_s != "#")
              value = "#{element.base}#{value}"
            elsif (!@uri.nil?)
              # we can use the document URI to build the URI for the element
              value = @uri + element_uri
            end
          end
          subject = URIRef.new(value)
        end
        
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID" #BNode with ID
          # we have a BNode with an identifier. First, we need to do syntax checking.
          if value =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # now we check to see if the graph has the value
            if @graph.has_bnode_identifier?(value)
              # if so, pull it in - no need to recreate objects.
              subject = @graph.get_bnode_by_identifier(value)
            else
              # if not, create a new one.
              subject = BNode.new(value)
            end
          end
        end
      end
    end
    
    def id_check?(id)
      !(!(id =~ /^[a-zA-Z_]\w*$/))
    end
    
    def parse_descriptions (node, subject = nil)
      node.each_element { |el|
        fail_check(el)
        # detect a subject
        subject = parse_subject(el) if subject.nil?
        
        # find a class
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
          #debugger
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
                parse_descriptions(cel.parent, object)
              end
            }
            
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
      }
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
    
    def url_helper(name, ns, base = nil)
      if ns != "" and !ns.nil?
        a = Addressable::URI.parse(ns) + Addressable::URI.parse(name)
      else
        a = Addressable::URI.parse(name)
      end
      if a.relative?
        if !base.nil?
          a = Addressable::URI.parse(base) + a
        elsif !@uri.nil?
          a = @uri + a
        end
      end
      
      return URIRef.new(a.to_s)
    end
    
  end
end
