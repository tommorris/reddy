require 'lib/uriref'

describe "URI References" do
  it "should output NTriples" do
    f = URIRef.new("http://tommorris.org/foaf/")
    f.to_ntriples.should == "<http://tommorris.org/foaf/>"
  end
  
  it "should handle Unicode symbols inside URLs" do
    f = URIRef.new("http://example.org/#Andr%E9")
  end
  
  it "do not contain any control characters (#x00 - #x1F, #x74-#x9F)" do
  end
  
  it "produce a valid URI character sequence (per RFC 2396 §2.1) representing an absolute URI with optional fragment identifier" do
  end
  
  it "must not be a relative URI" do
    lambda do
      URIRef.new("foo")
    end.should raise_error
  end
  
  it "should discourage use of %-escaped characters" do
  end
end