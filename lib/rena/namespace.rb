require 'rena/uriref'
require 'rena/graph'

class Namespace
  attr_accessor :short, :uri
   
  ## 
  # Creates a new namespace given a URI and the short name.
  #
  # ==== Example
  #   Namespace.new("http://xmlns.com/foaf/0.1/", "foaf") # => returns a new Foaf namespace
  #
  # @param [String] uri the URI of the namespace
  # @param [String] short the short name of the namespace
  #
  # ==== Returns
  # @return [Namespace] The newly created namespace.
  #
  # @raise [Error] Checks validity of the desired shortname and raises if it is incorrect.
  # @author Tom Morris
  
  def initialize(uri, short)
    @uri = uri
    if shortname_valid?(short)
      @short = short
    else
      raise
    end
  end
  
  def method_missing(methodname, *args)
    URIRef.new(@uri + methodname.to_s)
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
