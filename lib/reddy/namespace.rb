module Reddy
  class Namespace
    attr_accessor :short, :uri, :fragment
 
    ## 
    # Creates a new namespace given a URI and the short name.
    #
    # ==== Example
    #   Namespace.new("http://xmlns.com/foaf/0.1/", "foaf") # => returns a new Foaf namespace
    #
    # @param [String] uri the URI of the namespace
    # @param [String] short the short name of the namespace
    # @param [Boolean] fragment are the identifiers on this resource fragment identifiers? (e.g. '#')  Defaults to false.
    #
    # ==== Returns
    # @return [Namespace] The newly created namespace.
    #
    # @raise [Error] Checks validity of the desired shortname and raises if it is incorrect.
    # @author Tom Morris, Pius Uzamere

    def initialize(uri, short, fragment = false)
      @uri = uri
      @fragment = fragment
      if shortname_valid?(short)
        @short = short
      else
        raise
      end
    end

    ## 
    # Allows the construction of arbitrary URIs on the namespace.
    #
    # ==== Example
    #   foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf"); foaf.knows # => returns a new URIRef with URI "http://xmlns.com/foaf/0.1/knows"
    #   foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf", true); foaf.knows # => returns a new URIRef with URI "http://xmlns.com/foaf/0.1/#knows"
    #
    # @param [String] uri the URI of the namespace
    # @param [String] short the short name of the namespace
    # @param [Boolean] fragment are the identifiers on this resource fragment identifiers? (e.g. '#')  Defaults to false.
    #
    # ==== Returns
    # @return [URIRef] The newly created URIRegerence.
    #
    # @raise [Error] Checks validity of the desired shortname and raises if it is incorrect.
    # @author Tom Morris, Pius Uzamere

    def method_missing(methodname, *args)
      unless fragment
        URIRef.new(@uri + methodname.to_s)
      else
        URIRef.new(@uri + '#' + methodname.to_s)
      end
    end

    def bind(graph)
      if graph.class == Graph
        graph.bind(self)
      else
        raise
      end
    end

    private
    def shortname_valid?(shortname)
      if shortname =~ /[a-zA-Z_][a-zA-Z0-9_]+/
        return true
      else
        return false
      end
    end
  end
end
