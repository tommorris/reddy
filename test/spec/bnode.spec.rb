class BNode
  attr_accessor :identifier
  def initialize(identifier = nil)
    if identifier != nil
      @identifier = identifier
    else
      @identifier = "bn" + self.hash.to_s
    end
  end
  
  def to_n3
    "_:" + @identifier
  end
  
  def to_ntriples
    self.to_n3
  end
end

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