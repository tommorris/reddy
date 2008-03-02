require 'addressable/uri'
class URIRef
  attr_accessor :uri
  def initialize (string)
    self.uri = Addressable::URI.parse(string)
    if self.uri.relative?
      raise "URI must not be relative"
    end
    if !self.uri.to_s.match(/^javascript/).nil?
      raise "Javascript pseudo-URIs are not acceptable"
    end
  end
  
  def to_s
    @uri.to_s
  end
  
  def to_ntriples
    "<" + @uri.to_s + ">"
  end
end