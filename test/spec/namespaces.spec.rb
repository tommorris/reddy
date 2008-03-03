require 'lib/namespace'
describe "Namespaces" do
  it "should use method_missing to create URIRefs on the fly" do
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    foaf.knows.to_s.should == "http://xmlns.com/foaf/0.1/knows"
  end
  
  it "should have a URI" do
    lambda do
      test = Namespace.new(short='foaf')
    end.should raise_error
  end
  
  it "should have an XML and N3-friendly prefix" do
    pending "TODO: Thinking about how to test XML and N3 friendliness"
  end
  
  it "should be able to attach to the graph for subsitution" do
    pending "TODO: looking at best way to do this"
    # rdflib does this using graph.bind('prefix', namespace)
  end
end