require 'rena/uriref'
require 'rena/graph'
require 'rena/literal'
require 'rena/exceptions/uri_relative_exception'
require 'rena/exceptions/about_each_exception'
require 'rena/rexml_hacks'
require 'xml'

module Rena
  class RdfXmlParser
    SYNTAX_BASE = "http://www.w3.org/1999/02/22-rdf-syntax-ns"
    RDF_TYPE = SYNTAX_BASE + "#type"
    RDF_DESCRIPTION = SYNTAX_BASE + "#Description"

    attr_accessor :xml, :graph
    def initialize(xml_str, uri = nil)
      @excl = ["http://www.w3.org/1999/02/22-rdf-syntax-ns#resource",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#about",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#ID"]
      if uri != nil
        @uri = Addressable::URI.parse(uri)
      end
      @xml = LibXML::XML::Reader.string xml_str
      
      parse_rdf_doc
    end
    
    def parse_rdf_doc
      while @xml.read == 1
        parse_descriptions(@xml.name) if @xml.node_type == 1 && @xml.name =~ /RDF$/
      end
    end
    
    def is_element? (int)
      if int == 1 || int == 4
        true
      elsif int > 4
        result = int / 2.0
        if result == result.to_i
          true
        else
          false
        end
      else
        false
      end
    end
    
    def parse_descriptions (node_name)
      puts "parse_descriptions invoked"
      counter = 0
      while @xml.read == 1
        if @xml.node_type == 1
          counter = counter + 1
        end
        
        if @xml.node_type == 15
          counter = counter - 1
        end
        
        if counter == 0 && @xml.node_type == 15
#          puts 'We are at the end'
        end
        
        unless @xml.name == "#text"
          counter.times { print " " } unless @xml.node_type == 15
          print "< " if @xml.node_type == 1
#          print "> " if @xml.node_type == 15
          print @xml.name + " (" + counter.to_s + ") (" + @xml.node_type.to_s + ")" unless @xml.node_type == 15
          print " [DESC]" if is_element?(counter) && @xml.node_type == 1
          print "\n" if @xml.node_type == 1
        end
        
        # # attribute parsing
        # if @xml.has_attributes?
        #   #puts "can haz attrs"
        # end
        # 
        # # when counter>4, we have hit striping pattern gold
        # 
        # 
        # if @xml.node_type == 15 && @xml.name == node_name
        #   puts "end node detected"
        #   break
        # end
        # 
      end
    end
    
  end
end
