require 'rena/namespace'
require 'rena/bnode'
require 'rena/uriref'
require 'rena/literal'
require 'rena/triple'

module Rena
  class Graph
    attr_accessor :triples, :nsbinding

    def initialize
      @triples = []
      @nsbinding = {}
    end

    def size
      @triples.size
    end

    def each
      @triples.each { |value| yield value }
    end

    def each_with_subject(subject)
      @triples.each do |value|
        yield value if value.subject == subject
      end
    end

    def get_resource(subject)
      temp = []
      each_with_subject(subject) do |value|
        temp << subject
      end
      if temp.any?
        Resource.new(temp)
      end
    end

    ## 
    # Adds a triple to a graph directly from the intended subject, predicate, and object.
    #
    # ==== Example
    #   g = Graph.new; g.add_triple(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new) # => results in the triple being added to g; returns an array of g's triples
    #
    # @param [URIRef, BNode] s the subject of the triple
    # @param [URIRef] p the predicate of the triple
    # @param [URIRef, BNode, Literal, TypedLiteral] o the object of the triple
    #
    # ==== Returns
    # @return [Array] An array of the triples (leaky abstraction? consider returning the graph instead)
    #
    # @raise [Error] Checks parameter types and raises if they are incorrect.
    # @author Tom Morris

    def add_triple(s, p, o)
      @triples += [ Triple.new(s, p, o) ]
    end

    ## 
    # Adds an extant triple to a graph
    #
    # ==== Example
    #   g = Graph.new; t = Triple.new(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new); g << t) # => results in the triple being added to g; returns an array of g's triples
    #
    # @param [Triple] t the triple to be added to the graph
    #
    # ==== Returns
    # @return [Array] An array of the triples (leaky abstraction? consider returning the graph instead)
    #
    # @author Tom Morris


    def << (triple)
  #    self.add_triple(s, p, o)
      @triples += [ triple ]
    end

    ## 
    # Exports the graph to RDF in N-Triples form.
    #
    # ==== Example
    #   g = Graph.new; g.add_triple(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new); g.to_ntriples  # => returns a string of the graph in N-Triples form
    #
    # ==== Returns
    # @return [String] The graph in N-Triples.
    #
    # @author Tom Morris

    def to_ntriples
      @triples.collect do |t|
        t.to_ntriples
      end * "\n"
    end

    ## 
    # Creates a new namespace given a URI and the short name and binds it to the graph.
    #
    # ==== Example
    #   g = Graph.new; g.namespace("http://xmlns.com/foaf/0.1/", "foaf") # => binds the Foaf namespace to g
    #
    # @param [String] uri the URI of the namespace
    # @param [String] short the short name of the namespace
    #
    # ==== Returns
    # @return [Namespace] The newly created namespace.
    #
    # @raise [Error] Checks validity of the desired shortname and raises if it is incorrect.
    # @raise [Error] Checks that the newly created Namespace is of type Namespace and raises if it is incorrect.
    # @author Tom Morris

    def namespace(uri, short)
      self.bind Namespace.new(uri, short)
    end

    def bind(namespace)
      if namespace.class == Namespace
        @nsbinding["#{namespace.short}"] = namespace
      else
        raise
      end
    end

    def has_bnode_identifier?(bnodeid)
      temp_bnode = BNode.new(bnodeid)
      returnval = false
      @triples.each { |triple|
        if triple.subject.eql?(temp_bnode)
          returnval = true
          break
        end
        if triple.object.eql?(temp_bnode)
          returnval = true
          break
        end
      }
      return returnval
    end

    def get_bnode_by_identifier(bnodeid)
      temp_bnode = BNode.new(bnodeid)
      each do |triple|
        if triple.subject == temp_bnode
          return triple.subject
        end
        if triple.object == temp_bnode
          return triple.object
        end
      end
      return false
    end
    
    def get_by_type(object)
      out = []
      each do |t|
        next unless t.is_type?
        next unless case object
                    when String
                      object == t.object.to_s
                    when Regexp
                      object.match(t.object.to_s)
                    else
                      object == t.object
                    end
        out << t.subject
      end
      return out
    end
    
    def join(graph)
      if graph.class == Graph
        graph.each { |t| 
          self << t
        }
      else
        raise "join requires you provide a graph object"
      end
    end
  #  alias :add, :add_triple
    #  alias (=+, add_triple)
    private

  end
end
