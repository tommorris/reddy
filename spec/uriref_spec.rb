require 'webrick'
include WEBrick
require 'lib/rena'
#require 'lib/uriref'

describe "URI References" do
  it "should output NTriples" do
    f = URIRef.new("http://tommorris.org/foaf/")
    f.to_ntriples.should == "<http://tommorris.org/foaf/>"
  end
  
  it "should handle Unicode symbols inside URLs" do
    lambda do
      f = URIRef.new("http://example.org/#Andr%E9")
    end.should_not raise_error
  end
  
  # it "do not contain any control characters (#x00 - #x1F, #x74-#x9F)" do
  #   lambda do
  #     f = URIRef.new("http://tommorris.org/blog/")
  #     f.test_string("http://tommorris.org/blog")
  #   end.should_not raise_error
  #   
  #   lambda do
  #     f = URIRef.new("http://xmlns.com/foaf/0.1/knows")
  #     f.test_string("http://xmlns.com/foaf/0.1/knows")
  #   end.should_not raise_error
  # end
  
  it "should return the 'last fragment' name" do
    fragment = URIRef.new("http://example.org/foo#bar")
    fragment.short_name.should == "bar"
    
    path = URIRef.new("http://example.org/foo/bar")
    path.short_name.should == "bar"
    
    nonetest = URIRef.new("http://example.org/")
    nonetest.short_name.should == false
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

#   TEST turned off until parser is working.  
#   it "should allow the programmer to Follow His Nose" do
#     a = URIRef.new("http://127.0.0.1:3001/test")
#     
#     # server
#     test_proc = lambda { |req, resp|
#       resp['Content-Type'] = "application/rdf+xml"
#       resp.body = <<-EOF;
# <?xml version="1.0" ?>
# <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
#   <rdf:Description rdf:about="http://localhost:3001/test">
#     <foaf:name>Testy McTest</foaf:name>
#   </rdf:Description>
# </rdf:RDF>
#       EOF
#     }
#     test = HTTPServlet::ProcHandler.new(test_proc)
#     s = HTTPServer.new(:Port => 3001)
#     s.mount("/test", test)
#     trap("INT"){ s.shutdown }
#     thread = Thread.new { s.start }
#     graph = a.load_graph
#     s.shutdown
#     graph.class.should == Rena::Graph
#     graph.size.should == 1
#   end
end
