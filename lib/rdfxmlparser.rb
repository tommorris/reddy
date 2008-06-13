require 'lib/uriref'
require 'lib/graph'
require 'rexml/document'

class RdfXmlParser
  attr_accessor :xml
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

  def is_valid_uriref?
    
  end
  
  protected
  def parse_element (element)
    # It seems sensible at this point to add some documentaion for this method, since it does the bulk of the
    # work in parsing RDF/XML. It is rather cryptic. Before you meddle with it, it's highly advisable that you
    # read a few documents. RDF/XML really is the ugly duckling of the RDF world. It's pretty easy to produce
    # but a right pain in the backside to parse.
    # Read these documents before doing anything with this code.
    # 
    # RDF/XML Syntax Specification (2004), World Wide Web Consortium Recommendation
    # --> http://www.w3.org/TR/rdf-syntax-grammar/
    #   This document describes the detail of the RDF/XML syntax.
    # 
    # RDF: Concepts and Abstract Syntax (2004), World Wide Web Consortium Recommendation
    # --> http://www.w3.org/TR/rdf-concepts/
    #   This document describes the concepts underlying RDF, and the general process of parsing it.
    # 
    # "Why RDF model is different from the XML model", Tim Berners-Lee (1998) 'Design Issues'
    # --> http://www.w3.org/DesignIssues/RDF-XML.html
    # 
    # "The Sixteen Faces of Eve", Ian Davis
    # --> http://iandavis.com/blog/2005/09/the-sixteen-faces-of-eve
    #   Shows how a pair of three statements in RDF can be represented in plenty of different ways.
    # 
    # The reason why this bloody long comment is necessary is because too many people DON'T understand
    # that RDF/XML parsing is difficult and complicated. I will hopefully annotate this function to death
    # with comments because it's complicated. -TM
    
    # Figure out subject
    if element.attributes.get_attribute('resource') != nil
      if element.attributes.get_attribute('resource').namespace == "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        subject = URIRef.new(element.attributes.get_attribute('resource').to_s)
        print " < Detected subject: " + subject.to_s + " > "
      end
      # TODO: add other subject types here! - ID, nodeID etc.
    end
    
    element.attributes.each_attribute do |att|
      att_uri = att.namespace + att.name
      att_val = att.to_s
      if att_uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#resource"
        # do nothing
      else
        print " < Attribute triple: " + att_uri + " = " + att_val + " > "
#        @graph.add_triple(URIRef.new(subject), URIRef.new(uri), value)
      end
    end
      
    element.each_element do |e|
      # element parsing
      
      puts "< Element triple: " + e.namespace + e.name + " = " + e.to_s + " >"
      e.each_element do |se| # se = 'striped element'
        self.parse_element(se)
      end
    end
    
    # TODO: figure out subject
  end
  
  protected
  def get_value(element)
    # look for children
    if element.children.size != 0
      # do nothing for the moment
    else
      
    end
  end
  
  # protected
  # def iterator (node)
  #   node.each do |n|
  #     if n.is_a? REXML::Element
  #       puts n.
  #     end
  #     puts n.class
  #     if n.is_a? REXML::Element
  #       if n.has_attributes?
  #         n.attributes.entries.each do |att|
  #           if att[0] == "rdf:resource"
  #             puts att[1] + " is a resource"
  #           end
  #         end
  #         puts n.attributes.entries[0][1].inspect
  #       end
  #     end
  #     if !n.is_a? REXML::Text
  #       self.iterator n.children
  #     end
  #   end
  # end
  
end