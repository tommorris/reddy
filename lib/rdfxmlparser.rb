require 'lib/uriref'
require 'lib/graph'
require 'lib/literal'
require 'rexml/document'
require 'lib/exceptions/uri_relative_exception'

class RdfXmlParser
  attr_accessor :xml, :graph
  def initialize (xml_str)
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
      if uri == resourceuri #specified resource
        begin
          possible_subject = URIRef.new(value)
        rescue UriRelativeException
          # URI should be absolutized here
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
      # add other subject detection subroutines here
    }
    if subject == nil
      subject = BNode.new
    end
    return subject
  end
  
  protected
  def parse_element (element, subject = nil)
    if subject == nil
      # figure out subject
      subject = self.get_uri_from_atts(element, true)
    end

    # type parsing
    type = URIRef.new(element.namespace + element.name)
    unless type.to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#Description"
      @graph.add_triple(subject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), type)
    end
    
    # attribute parsing
    element.attributes.each_attribute { |att|
      uri = att.namespace + att.name
      value = att.to_s
      excl = ["http://www.w3.org/1999/02/22-rdf-syntax-ns#resource", "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID", "http://www.w3.org/1999/02/22-rdf-syntax-ns#about"]
      unless excl.member? uri
        @graph.add_triple(subject, URIRef.new(uri), Literal.new(value))
      end
    }

    # element parsing
    element.each_element { |e|
      uri = e.namespace + e.name
      if e.has_elements?
        # subparsing
        e.each_element { |se| #se = 'striped element'
          object = self.get_uri_from_atts(se, true)
          @graph.add_triple(subject, URIRef.new(uri), object)
          self.parse_element(se, object)
        }
      elsif e.has_attributes?
        # get object out
        object = self.get_uri_from_atts(e)
        @graph.add_triple(subject, URIRef.new(uri), object)
      elsif e.has_text?
        @graph.add_triple(subject, URIRef.new(uri), Literal.new(e.text))
      end
    }
  end
  
end