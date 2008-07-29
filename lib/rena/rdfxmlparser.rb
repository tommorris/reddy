require 'rena/uriref'
require 'rena/graph'
require 'rena/literal'
require 'rena/exceptions/uri_relative_exception'
require 'rena/exceptions/about_each_exception'
require 'rena/rexml_hacks'

module Rena
  class RdfXmlParser
    attr_accessor :xml, :graph
    def initialize(xml_str, uri = nil)
      @excl = ["http://www.w3.org/1999/02/22-rdf-syntax-ns#resource", "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID", "http://www.w3.org/1999/02/22-rdf-syntax-ns#about", "http://www.w3.org/1999/02/22-rdf-syntax-ns#ID"]
      if uri != nil
        @uri = Addressable::URI.parse(uri)
      end
      @xml = REXML::Document.new(xml_str)
  #    self.iterator @xml.root.children
      if self.is_rdf?
        @graph = Graph.new
        @xml.root.each_element { |e|
          self.parse_element e
        }
  #      puts @graph.size
      end
    end

    def is_rdf?
      trigger = false
      @xml.each_element do |e|
        if e.namespaces.has_value? "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          trigger = true
        end
      end
      return trigger
    end

    protected
    def get_uri_from_atts (element, aboutmode = false)
      if aboutmode == false
        resourceuri = "http://www.w3.org/1999/02/22-rdf-syntax-ns#resource"
      else
        resourceuri = "http://www.w3.org/1999/02/22-rdf-syntax-ns#about"
      end
  
      subject = nil
      element.attributes.each_attribute { |att|
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
          begin
            possible_subject = URIRef.new(value)
          rescue UriRelativeException
            if value[0..0].to_s != "#"
              value = "#" + value
            end
            begin
              value = URIRef.new(element.base + value)
            rescue UriRelativeException
              # still not a URI
              raise
            else
              subject = value
            end
          else
            subject = possible_subject
            break
          end
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
    
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#ID"
          begin
            # check for base
            if att.element.base?
              subject = att.element.base.to_s + value
            elsif @uri != nil
              compound = @uri.to_s + "#" + value
              subject = compound.to_s
            else
              raise "Needs to have an ID"
            end
  #        rescue UriRelativeException
          end
        end

        # add other subject detection subroutines here
      }
      if subject.class == NilClass
        subject = BNode.new
      end
      return subject
    end

    protected
    def parse_element (element, subject = nil, resource = false)
      if subject == nil
        # figure out subject
        subject = self.get_uri_from_atts(element, true)
      end

      # type parsing
      if resource == true
        type = URIRef.new(element.namespace + element.name)
        unless type.to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#Description"
          @graph.add_triple(subject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), type)
        end
      end
  
      # attribute parsing
      element.attributes.each_attribute { |att|
        uri = att.namespace + att.name
        value = att.to_s
    
        unless @excl.member? uri
          @graph.add_triple(subject, URIRef.new(uri), Literal.new(value))
        end
      }

      # element parsing
      element.each_element { |e|
        self.parse_resource_element e, subject
      }
    end

    def parse_resource_element e, subject
      uri = e.namespace + e.name
      if e.attributes.get_attribute_ns("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "parseType").to_s == "Literal"
        @graph.add_triple(subject, URIRef.new(uri), TypedLiteral.new(e.children.to_s.strip, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"))
      elsif e.has_elements?
        # subparsing
        e.each_element { |se| #se = 'striped element'
          if e.attributes.get_attribute_ns("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "parseType").to_s == "Resource"
            object = BNode.new
          else
            object = self.get_uri_from_atts(se, true)
          end
          @graph.add_triple(subject, URIRef.new(uri), object)
          self.parse_element(se, object, true)
        }
      elsif e.attributes.get_attribute_ns("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "datatype")
        @graph.add_triple(subject, URIRef.new(uri), TypedLiteral.new(e.text, e.attributes.get_attribute_ns("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "datatype").to_s.strip))
      elsif e.has_attributes?
        # get object out
        object = self.get_uri_from_atts(e)
        @graph.add_triple(subject, URIRef.new(uri), object)
      elsif e.has_text?
        if e.lang?
          @graph.add_triple(subject, URIRef.new(uri), Literal.new(e.text, e.lang))
        else
          @graph.add_triple(subject, URIRef.new(uri), Literal.new(e.text))                    
        end
      end
    end

  end
end