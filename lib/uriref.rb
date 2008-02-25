require 'uri'
class URIRef
  attr_accessor :uri
  def initialize (string)
    self.uri = URI.parse(string)
  end
  
  def to_ntriples
    "<" + @uri.to_s + ">"
  end
end