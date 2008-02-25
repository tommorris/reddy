require '../../bnode.rb'

class Triple
  attr_accessor :subject, :object, :predicate
  def to_ntriples
    @subject.to_ntriples + " " + @predicate.to_ntriples + " " + @object.to_ntriples + " ."
  end
end

describe "Triples" do
  it "should have a subject" do
    f = Triple.new
    f.subject = BNode.new
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
  end
end