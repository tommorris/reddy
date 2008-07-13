require 'rena/uriref'
require 'rena/graph'

class Namespace
  attr_accessor :short, :uri
  
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
