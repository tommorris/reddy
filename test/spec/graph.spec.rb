require 'lib/bnode'
require 'lib/uriref'
require 'lib/triple'
require 'lib/literal'
require 'lib/graph'
describe "Graphs" do
  it "should allow you to add one or more triples" do
    lambda do
      f = Graph.new
      f.add_triple(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new)
    end.should_not raise_error
  end
  
  it "should tell you how large the graph is" do
    f = Graph.new
    5.times do
      f.add_triple BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new
    end
    f.size.should == 5
  end

  it "should support << as an alias for add_triple" do
    lambda do
      f = Graph.new
      f << Triple.new(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new)
    end.should_not raise_error
  end
end