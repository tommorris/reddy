require 'lib/bnode'
describe "Blank nodes" do
  it "should accept a custom identifier" do
    b = BNode.new('foo')
    b.identifier.should == "foo"
  end
  
  it "should be expressible in N3 and NT syntax" do
    b = BNode.new('test')
    b.to_n3.should == "_:test"
    b.to_ntriples.should == b.to_n3
  end
end