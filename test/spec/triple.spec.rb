require 'lib/rena'

describe "Triples" do
  it "should have a subject" do
    f = Triple.new(BNode.new, URIRef.new('http://xmlns.com/foaf/0.1/knows'), BNode.new)
    f.subject.class.should == BNode
    # puts f.to_ntriples
  end
  
  it "should require that the subject is a URIRef or BNode" do
   lambda do
     Triple.new(Literal.new("foo"), URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new)
    end.should raise_error
  end
  
  it "should require that the predicate is a URIRef" do
    lambda do
      Triple.new(BNode.new, BNode.new, BNode.new)
    end.should raise_error
  end
  
  it "should require that the object is a URIRef, BNode, Literal or Typed Literal" do
    lambda do
      Triple.new(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), [])
    end.should raise_error
  end
  
  it "should emit an NTriple" do
    f = Triple.new(URIRef.new("http://tommorris.org/foaf#me"), URIRef.new("http://xmlns.com/foaf/0.1/name"), Literal.new("Tom Morris"))
    f.to_ntriples.should == "<http://tommorris.org/foaf#me> <http://xmlns.com/foaf/0.1/name> \"Tom Morris\" ."
  end  
end
