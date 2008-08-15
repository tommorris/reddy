require 'lib/rena'

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
    count = 0
    f.each do |t|
      count = count + 1
      t.class.should == Triple
    end
    count.should == 3
  end
  
  it "should allow iteration over a particular subject" do
    f = Graph.new
    ex = Namespace.new("http://example.org/", "ex")
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    f << Triple.new(ex.john, foaf.knows, ex.jane)
    f << Triple.new(ex.jane, foaf.knows, ex.rick)
    f << Triple.new(ex.rick, foaf.knows, ex.john)
    count = 0
    f.each_with_subject(ex.john) do |t|
      count = count + 1
      t.class.should == Triple
    end
    count.should == 1
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
    
  it "should follow the specification as to output identical triples" do
    pending
  end
  
  it "should be able to integrate another graph" do
    f = Graph.new
    f.add_triple(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new)
    g = Graph.new
    g.join(f)
    g.size.should == 1
    
    h = Graph.new
    lambda do
      h.join("")
    end.should raise_error
  end
  
  it "should give you a list of resources of a particular type" do
    f = Graph.new
    person = URIRef.new("http://xmlns.com/foaf/0.1/Person")
    f.add_triple(URIRef.new("http://example.org/joe"), URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), URIRef.new("http://xmlns.com/foaf/0.1/Person"))
    f.add_triple(URIRef.new("http://example.org/jane"), URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), URIRef.new("http://xmlns.com/foaf/0.1/Person"))
    f.size.should == 2
    
    f.get_by_type("http://xmlns.com/foaf/0.1/Person").size.should == 2
    f.get_by_type("http://xmlns.com/foaf/0.1/Person")[0].to_s.should == "http://example.org/joe"
    f.get_by_type("http://xmlns.com/foaf/0.1/Person")[1].to_s.should == "http://example.org/jane"
  end
end
