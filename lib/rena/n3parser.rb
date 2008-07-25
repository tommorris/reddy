require 'rena/graph'
require 'treetop'

Treetop.load(File.join(File.dirname(__FILE__), "n3_grammer"))

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
        puts "Expected #{tf.expected_string.inspect} (#{tf.index})- '#{string[tf.index,10].inspect}'"
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
      Literal.new(object.elements[1].text_value)
    end
  end

    # pp objects.object
    # if (objects.respond_to? :object and objects.object.respond_to? :anonnode)
    #   pp 'foo'
    # elsif (objects.respond_to? :object and objects.respond_to? :object_list)
    #   result << process_node(objects.object)
    #   result << process_objects(objects.object_list)
    # elsif (objects.respond_to? :localname)
    #   result << process_node(objects)
    # elsif (objects.respond_to? :uri)
    #   result << URIRef.new(objects.uri.text_value)
    # else
    #   result << Literal.new(objects.elements[1].text_value)
    # end
  #   result.flatten
  # end
    
  def build_uri(prefix, localname)
    prefix = '__local__' if prefix.nil?
    if (prefix=='_')
      BNode.new(localname)
    else
      @graph.nsbinding[prefix].send(localname)
    end
  end

  
end

# # string = %[
# #   <rdf:RDF xmlns="http://example.org/#"
# #       xmlns:log="http://www.w3.org/2000/10/swap/log#"
# #       xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
# # 
# #       <rdf:Description rdf:about="http://example.org/#Subject">
# #           <predicate rdf:resource="http://example.org/#ObjectP"/>
# #       </rdf:Description>
# #   </rdf:RDF>
# # ]
# # parser = RdfXmlParser.new(string)
# # puts parser.graph.to_ntriples
# 
# [ 'simple-01.n3', 
#   'simple-02.n3',
#   'simple-03.n3',
#   'simple-04.n3',
#   'simple-05.n3',
#   'simple-06.n3',
#   'simple-07.n3',
#   'on_now-01.n3',
#  ].each do |f|
#   string = File.read("test/n3p_tests/#{f}")
#   parser = N3Parser.new(string)
#   puts f
#   puts parser.graph.to_ntriples
# end
