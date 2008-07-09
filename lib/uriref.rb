require 'addressable/uri'
require 'lib/exceptions/uri_relative_exception'

class URIRef
  attr_accessor :uri
  def initialize (string)
    self.test_string(string)
    @uri = Addressable::URI.parse(string)
    if @uri.relative?
      raise UriRelativeException, "<" + @uri.to_s + ">"
    end
    if !@uri.to_s.match(/^javascript/).nil?
      raise "Javascript pseudo-URIs are not acceptable"
    end
  end
  
  def to_s
    @uri.to_s
  end
  
  def to_ntriples
    "<" + @uri.to_s + ">"
  end
  
  # def test_string (string)
  #   string.each_byte do |b|
  #     if b >= 0 and b <= 31
  #       raise "URI must not contain control characters"
  #     end
  #   end
  # end
end