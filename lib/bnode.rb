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