require 'lib/rena'

module Rena
  if require 'xml'
    include Rena
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
      @graph = Rena::Graph.new
      @xml = LibXML::XML::Reader.string xml_str
      
      parse_rdf_doc
    end
    
    protected
    def parse_rdf_doc
      while @xml.read == 1
        parse_descriptions(@xml.name) if @xml.node_type == 1 && @xml.name =~ /RDF$/
      end
    end
    
    def is_new_node? (int)
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
    
    def url_helper(name, ns)
      ns + name.match(/\:?(.+)$/)[1]
    end
    
    def parse_descriptions (node_name)
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
        
        if @xml.node_type == 1
          
          if is_new_node?(counter)
            if @xml.has_attributes?
              while @xml.move_to_next_attribute == 1
                if @xml.name =~ /about$/
                  currentsubject = URIRef.new(@xml.value)
                end
              end
            else
              currentsubject = BNode.new
            end
            
            @xml.move_to_first_attribute
            while @xml.move_to_next_attribute == 1
              unless @xml.name =~ /^rdf:(.+)$/
                # TODO: make this not suck
                @graph.add_triple(currentsubject, url_helper(@xml.name, @xml.namespace_uri), @xml.value)
                
              end
            end
          end
          
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
end
