require 'rexml/document'

class RdfXmlParser
  attr_accessor :xml
  def initialize
    # TODO: put in file reader and URL reader and detection code
    @xml = REXML::Document.new(File.open("/Users/tommorris/code/Ruby/rena/test/xml.rdf"))
    self.iterator @xml.root.children
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

f = RdfXmlParser.new
#puts f.xml.root.inspect