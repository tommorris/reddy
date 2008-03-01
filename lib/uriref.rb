require 'uri'
class URIRef
  attr_accessor :uri
  def initialize (string)
    self.uri = URI.parse(string)
    if self.uri.relative?
      raise "URI must not be relative"
    end
  end
  
  def to_s
    @uri.to_s
  end
  
  def to_ntriples
    "<" + @uri.to_s + ">"
  end
end