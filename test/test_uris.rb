require 'test/unit'
require 'uri'
require 'cgi'
require 'rubygems'
require 'addressable/uri'

class TestUris < Test::Unit::TestCase
  def test_encoding
    f = Addressable::URI.parse("http://example.org/André")
    assert_equal("http://example.org/André", f.to_s)
    assert_equal(false, f.relative?)
  end
end