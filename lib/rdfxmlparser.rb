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
#    puts "Invoked!"
    subject = "" # declare so it works outside block
    type = URIRef.new(element.namespace + element.name)
    element.attributes.each_attribute { |att| 
      uri = att.namespace + att.name
      value = att.to_s
#      puts uri + " --> " + value
      if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#resource"
        subject = value
        # TODO: add other subject types here! - ID, nodeID etc.
      else
        @graph.add_triple(URIRef.new(subject), uri, value)
      end
    }
    puts subject
#    puts type
    if type.to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#Description"
      # do nothing
    else
      # create a type triple
    end
    # TODO: figure out subject
    # TODO: add attribute parsing
    element.each_element { |e|
      # element parsing
      e.each_element { |se| # se = 'striped element'
        self.parse_element(se)
      }
    }
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