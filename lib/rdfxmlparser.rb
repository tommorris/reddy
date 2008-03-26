require 'rexml/document'

class RdfXmlParser
  attr_accessor :xml
  def initialize (xml_str)
    @xml = REXML::Document.new(xml_str)
#    self.iterator @xml.root.children
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
  def iterator (node)
    node.each do |n|
      puts n.class
      if n.is_a? REXML::Element
        if n.has_attributes?
          n.attributes.entries.each do |att|
            if att[0] == "rdf:resource"
              puts att[1] + " is a resource"
            end
          end
#          puts n.attributes.entries[0][1].inspect
        end
      end
      if !n.is_a? REXML::Text
        self.iterator n.children
      end
    end
  end
  
end