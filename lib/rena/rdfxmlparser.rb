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
    def parse_subject(el)
      if el.attributes.get_attribute_ns(SYNTAX_BASE, "about")
        return URIRef.new(el.attributes.get_attribute_ns(SYNTAX_BASE, "about").value)
      elsif el.attributes.get_attribute_ns(SYNTAX_BASE, "ID")
        return url_helper("#" + el.attributes.get_attribute_ns(SYNTAX_BASE, "ID").value, "", el.base)
      elsif el.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID")
        return BNode.new(el.attributes.get_attribute_ns(SYNTAX_BASE, "nodeID").value)
      else
        return BNode.new
      end
    end
    
    private
    def parse_descriptions (node, subject = nil)
      node.each_element { |el|
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
                @graph.add_triple(subject, predicate, contents.content)
              end
            }
            child.each_element {|cel|
              object = parse_subject(cel)
              if child.attributes.get_attribute_ns(SYNTAX_BASE, "parseType")
                case child.attributes.get_attribute_ns(SYNTAX_BASE, "parseType").value
                when "XMLLiteral"; @graph.add_triple(subject, predicate, Literal.typed(cel.namespaced_to_s, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"))
                when "Literal"; @graph.add_triple(subject, predicate, cel.to_s)
                when "Resource"
                  resource = BNode.new
                  @graph.add_triple(subject, predicate, resource)
                  parse_descriptions(cel, resource)
                #when "Collection";
                end
              else
                @graph.add_triple(subject, predicate, object)
                parse_descriptions(cel.parent, object)
              end
            }
        }
      }
    end
          
    private
    def extract_name(str)
      if str !=~ /(.+)\:(.+)/
        return str
      else
        return name.match(/[\:|](.+)$/)[1]
      end
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
