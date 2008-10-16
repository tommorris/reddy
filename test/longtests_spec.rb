describe "Rena library"
  it "should allow the programmer to Follow His Nose" do
    a = URIRef.new("http://127.0.0.1:3001/test")
    test_proc = lambda { |req, resp|
      resp['Content-Type'] = "application/rdf+xml"
      resp.body = <<-EOF;
<?xml version="1.0" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
 <rdf:Description rdf:about="http://localhost:3001/test">
   <foaf:name>Testy McTest</foaf:name>
 </rdf:Description>
</rdf:RDF>
EOF
      }
      test = HTTPServlet::ProcHandler.new(test_proc)
      s = HTTPServer.new(:Port => 3001)
      s.mount("/test", test)
      trap("INT"){ s.shutdown }
      thread = Thread.new { s.start }
      graph = a.load_graph
      s.shutdown
      graph.class.should == Rena::Graph
      graph.size.should == 1
  end
end
