require 'test/unit'
require 'uri'
require 'cgi'

class TestUris < Test::Unit::TestCase
  def test_encoding
    f = URI.parse("http://example.org/André")
    assert_equal("http://example.org/André", f.to_s)
    assert_equal("Andr%E9", CGI.escape("André"))
  end
end