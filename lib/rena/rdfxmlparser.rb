require 'ruby-debug'
require 'lib/rena'
include Rena

module Rena
  if require 'xml'
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
        if uri != nil
          @uri = Addressable::URI.parse(uri)
        end
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
      def parse_descriptions (node)
        node.each_element { |el|
          # detect a subject
          subject = URIRef.new(el.attributes.get_attribute_ns(SYNTAX_BASE, "about").value)
          
          # find a class
          unless el.name == "Description" && el.namespace_node.href == SYNTAX_BASE
            @graph.add_triple(subject, RDF_TYPE, url_helper(el.name, el.namespace_node.href, el.base))
          end
          
          # read each attribute that's not in SYNTAX_BASE
          el.attributes.each { |att|
            @graph.add_triple(subject, url_helper(att.name, att.ns.href, el.base), att.value) unless att.ns.href == SYNTAX_BASE
          }
          
          el.each_element {|child|
            # puts child
            # parse child elements
            # puts child.to_s
            # puts child.value
            # child.children.each { |i|
            #   puts i.class
            # }
          }
        }
      end

      protected
      def parse_rdf_doc
        while @xml.read == 1
          parse_descriptions(@xml.name) if @xml.node_type == 1 && @xml.name =~ /RDF$/
        end
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
        if base.nil?
          ns + extract_name(name)
        else
          create_uri(ns + extract_name(name), base)
        end
      end
    
      # def parse_descriptions (node_name)
      #   # debugger
      #   counter = @xml.depth
      #   while @xml.read == 1 && @xml.depth >= counter 
      #     if @xml.node_type == 1
      #     
      #       if is_new_node?(@xml.depth)
      #         if @xml.has_attributes?
      #           parsed_attributes = Hash.new
      #           rdf_ns_uri = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      #           while @xml.move_to_next_attribute == 1
      #             case
      #             when @xml.namespace_uri == rdf_ns_uri && @xml.name =~ /about$/
      #               parsed_attributes[:about] = create_uri(@xml.value, @xml.base_uri)
      #             when @xml.namespace_uri == rdf_ns_uri && @xml.name =~ /nodeID$/
      #               parsed_attributes[:nodeID] = BNode.new @xml.value
      #             # when # ID
      #             # when 
      #             end
      #           end
      #           if parsed_attributes[:about]
      #             currentsubject = parsed_attributes[:about]
      #           elsif parsed_attributes[:nodeID]
      #             currentsubject = parsed_attributes[:nodeID]
      #           elsif parsed_attributes[:ID]
      #             currentsubject = parsed_attributes[:ID]
      #           else
      #             currentsubject = BNode.new
      #           end
      #         else
      #           currentsubject = BNode.new
      #         end
      #         
      #         @xml.move_to_first_attribute
      #         while @xml.move_to_next_attribute == 1
      #           unless @xml.name =~ /^rdf:(.+)$/
      #             # TODO: make this not suck
      #             @graph.add_triple(currentsubject, url_helper(@xml.name, @xml.namespace_uri), Literal.untyped(@xml.value))
      #           end
      #         end
      #         # detect class
      #         
      #         parse_contents(currentsubject)
      #         # debugger
      #       end
      #     end
      #   end
      # end
      # 
      # def parse_contents(currentsubject)
      #   counter = @xml.depth
      #   while @xml.read == 1 && counter >= @xml.depth
      #     if @xml.node_type == 1
      #       # debugger
      #       subject = currentsubject # may vary later
      #       predicate = url_helper(@xml.name, @xml.namespace_uri)
      #       if @xml.has_attributes?
      #         rdf_ns_uri = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      #         while @xml.move_to_next_attribute == 1
      #           if @xml.namespace_uri == rdf_ns_uri && @xml.name =~ /resource$/
      #             object = create_uri(@xml.value, @xml.base_uri)
      #             # puts object.to_s
      #           elsif @xml.namespace_uri == rdf_ns_uri && @xml.name =~ /datatype$/
      #             type_uri = @xml.value
      #             while @xml.read == 1 && @xml.node_type != 15
      #               if @xml.node_type == 3
      #                 value = @xml.value
      #                 break
      #               end
      #             end
      #             object = Literal.typed(value, type_uri)
      #           end
      #         end
      #       else
      #         unless @xml.value.nil?
      #           object = Literal.untyped(@xml.value)
      #         end
      #       end
      # 
      #       unless object.nil?
      #         @graph.add_triple(subject, predicate, object)
      #       end
      #       # debugger
      #     end
      #   end
      # end
      
      def create_uri (uri, base)
        begin
          a = URIRef.new(uri)
        rescue UriRelativeException
          a = URIRef.new(base) + URIRef.new(uri)
        end
        return a
      end
    end
  end
end
