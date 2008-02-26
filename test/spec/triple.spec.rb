require 'lib/triple'
require 'lib/uriref'
require 'lib/bnode'
require 'lib/literal'

describe "Triples" do
  it "should have a subject" do
    f = Triple.new(BNode.new, URIRef.new('http://xmlns.com/foaf/0.1/knows'), BNode.new)
    f.subject.class.should == BNode
    # puts f.to_ntriples
  end
  it "should require that the subject is a URIRef or BNode" do
  end
  it "should have a predicate" do
  end
  it "should require that the subject is a URIRef" do
  end
  it  "should have an object" do
  end
  it "should require that the object is a URIRef, BNode, Literal or Typed Literal" do
  end
  it "should emit an NTriple" do
    f = Triple.new(URIRef.new("http://tommorris.org/foaf#me"), URIRef.new("http://xmlns.com/foaf/0.1/name"), Literal.new("Tom Morris"))
    f.to_ntriples.should == "<http://tommorris.org/foaf#me> <http://xmlns.com/foaf/0.1/name> \"Tom Morris\" ."
  end
end