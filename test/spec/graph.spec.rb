require 'lib/bnode'
require 'lib/uriref'
require 'lib/triple'
require 'lib/literal'
require 'lib/graph'
require 'lib/namespace'
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
  
  it "should output NTriple" do
    f = Graph.new
    ex = Namespace.new("http://example.org/", "ex")
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    f << Triple.new(ex.john, foaf.knows, ex.jane)
    f << Triple.new(ex.jane, foaf.knows, ex.rick)
    f << Triple.new(ex.rick, foaf.knows, ex.john)
    nt = "<http://example.org/john> <http://xmlns.com/foaf/0.1/knows> <http://example.org/jane> .\n<http://example.org/jane> <http://xmlns.com/foaf/0.1/knows> <http://example.org/rick> .\n<http://example.org/rick> <http://xmlns.com/foaf/0.1/knows> <http://example.org/john> .\n"
    f.to_ntriples.should == nt
  end
  
  it "should allow iteration" do
    f = Graph.new
    ex = Namespace.new("http://example.org/", "ex")
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    f << Triple.new(ex.john, foaf.knows, ex.jane)
    f << Triple.new(ex.jane, foaf.knows, ex.rick)
    f << Triple.new(ex.rick, foaf.knows, ex.john)
    # count = 0
    # f.each do |t|
    #   count = count + 1
    #   t.class.should == Triple
    # end
    # count.should == 3
    pending "Need to finish"
  end
  
  it "should have an error log for parsing errors" do
    pending "TODO: implement an error log at the graph level"
  end
  
  it "should follow the specification as to output identical triples" do
    pending
  end
end