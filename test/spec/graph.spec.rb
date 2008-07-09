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
  
  it "should be able to determine whether or not it has existing BNodes" do
    f = Graph.new
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    f << Triple.new(BNode.new('john'), foaf.knows, BNode.new('jane'))
    f.has_bnode_identifier?('john').should == true
    f.has_bnode_identifier?('jane').should == true
    f.has_bnode_identifier?('jack').should == false
  end
  
  it "should be able to return BNodes on demand" do
    f = Graph.new
    john = BNode.new('john')
    jane = BNode.new('jane')
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    f << Triple.new(john, foaf.knows, jane)
    f.get_bnode_by_identifier('john').should == john
    f.get_bnode_by_identifier('jane').should == jane
  end
  
  it "should allow you to create and bind Namespace objects on-the-fly" do
    f = Graph.new
    f.namespace("http://xmlns.com/foaf/0.1/", "foaf")
    f.nsbinding["foaf"].uri.should == "http://xmlns.com/foaf/0.1/"
  end
  
  it "should not allow you to bind things other than namespaces" do
    lambda do
      f = Graph.new
      f.bind(false)
    end.should raise_error
  end
  
  it "should have an error log for parsing errors" do
    pending "TODO: implement an error log at the graph level"
  end
  
  it "should follow the specification as to output identical triples" do
    pending
  end
end