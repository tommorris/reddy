require 'rena/graph'
require 'treetop'

Treetop.load(File.join(File.dirname(__FILE__), "n3_grammar"))

module Rena
  class N3Parser
    attr_accessor :graph

    ## 
    # Creates a new parser for N3 (or Turtle).
    #
    # @param [String] n3_str the Notation3/Turtle string
    # @param [String] uri the URI of the document
    #
    # @author Patrick Sinclair (metade)
    def initialize(n3_str, uri=nil)
      @uri = Addressable::URI.parse(uri) unless uri.nil?
      parser = N3GrammerParser.new
      document = parser.parse(n3_str)
      if document
        @graph = Graph.new
        process_directives(document)
        process_statements(document)
      else
        parser.terminal_failures.each do |tf|
          puts "Expected #{tf.expected_string.inspect} (#{tf.index})- '#{n3_str[tf.index,10].inspect}'"
        end
      end
    end

    protected

    def process_directives(document)
      directives = document.elements.find_all { |e| e.elements.first.respond_to? :directive }
      directives.map! { |d| d.elements.first }
      directives.each { |d| namespace(d.uri_ref2.uri.text_value, d.nprefix.text_value) }
    end

    def namespace(uri, short)
      short = '__local__' if short == ''
      @graph.namespace(uri, short)
    end

    def process_statements(document)
      subjects = document.elements.find_all { |e| e.elements.first.respond_to? :subject }
      subjects.map! { |s| s.elements.first }
      subjects.each do |s|
        subject = process_node(s.subject)
        properties = process_properties(s.property_list)
        properties.each do |p|      
          predicate = process_verb(p.verb)
          objects = process_objects(p.object_list)
          objects.each { |object| triple(subject, predicate, object) }
        end
      end
    end

    def triple(subject, predicate, object)
      @graph.add_triple(subject, predicate, object)
    end

    def process_anonnode(anonnode)
      bnode = BNode.new
      properties = process_properties(anonnode.property_list)
      properties.each do |p|      
        predicate = process_node(p.verb)
        objects = process_objects(p.object_list)
        objects.each { |object| triple(bnode, predicate, object) }
      end
      bnode
    end

    def process_verb(verb)
      return URIRef.new('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') if (verb.text_value=='a')
      return process_node(verb)
    end

    def process_node(node)
      if (node.respond_to? :uri)
        URIRef.new(node.uri.text_value)
      else      
        prefix = (node.respond_to? :nprefix) ? node.nprefix.text_value : nil
        localname = node.localname.text_value
        build_uri(prefix, localname)
      end
    end

    def process_properties(properties)
      result = []
      result << properties if (properties.respond_to? :verb)
      result << process_properties(properties.property_list) if (properties.respond_to? :property_list)
      result.flatten
    end

    def process_objects(objects)
      result = []
      if (objects.respond_to? :object)
        result << process_object(objects.object)
      else
        result << process_object(objects)
      end
      result << process_objects(objects.object_list) if (objects.respond_to? :object_list)
      result.flatten
    end

    def process_object(object)
      if (object.respond_to? :localname or object.respond_to? :uri)
        process_node(object)
      elsif (object.respond_to? :property_list)
        process_anonnode(object)
      else
        process_literal(object)
      end
    end
    
    def process_literal(object)
      encoding, language = nil, nil
      string, type = object.elements
      
      unless type.elements.nil?
        if (type.elements[0].text_value=='@')
          language = type.elements[1].text_value
        else
          encoding = type.elements[1].text_value
        end
      end

      if (encoding.nil?)
        Literal.untyped(string.elements[1].text_value, language)
      else
        Literal.typed(string.elements[1].text_value, encoding)
      end      
    end
    
    def build_uri(prefix, localname)
      prefix = '__local__' if prefix.nil?
      if (prefix=='_')
        BNode.new(localname)
      else
        @graph.nsbinding[prefix].send(localname)
      end
    end
  end
end
