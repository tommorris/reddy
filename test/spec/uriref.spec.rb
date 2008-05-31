require 'lib/uriref'

describe "URI References" do
  it "should output NTriples" do
    f = URIRef.new("http://tommorris.org/foaf/")
    f.to_ntriples.should == "<http://tommorris.org/foaf/>"
  end
  
  it "should handle Unicode symbols inside URLs" do
    f = URIRef.new("http://example.org/#Andr%E9").should_not raise_error
  end
  
  it "do not contain any control characters (#x00 - #x1F, #x74-#x9F)" do
    lambda do
      f = URIRef.new("http://tommorris.org/blog/")
      f.test_string("http://tommorris.org/blog")
    end.should_not raise_error
    
    lambda do
      f = URIRef.new("http://xmlns.com/foaf/0.1/knows")
      f.test_string("http://xmlns.com/foaf/0.1/knows")
    end.should_not raise_error
  end
  
  it "produce a valid URI character sequence (per RFC 2396 §2.1) representing an absolute URI with optional fragment identifier" do
    pending "TODO: figure out a series of tests for RFC 2396 §2.1 adherence"
  end
  
  it "should throw errors on suspicious protocols and non-protocols" do
    lambda do
      URIRef.new("javascript:alert(\"pass\")")
    end.should raise_error
  end
  
  it "must not be a relative URI" do
    lambda do
      URIRef.new("foo")
    end.should raise_error
  end
  
  it "should discourage use of %-escaped characters" do
    pending "TODO: figure out a way to discourage %-escaped character usage"
  end
end