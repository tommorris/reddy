class BNode
  attr_accessor :identifier
  def initialize(identifier = nil)
    if identifier != nil && self.valid_id?(identifier) != false
      @identifier = identifier
    else
      @identifier = "bn" + self.hash.to_s
    end
  end
  
  def eql? (eql)
    if self.identifier == eql.identifier
      true
    else
      false
    end
  end
  
  def to_n3
    "_:" + @identifier
  end
  
  def to_ntriples
    self.to_n3
  end
  
  def to_s
    @identifier
  end  
  
  # TODO: add valid bnode name exceptions?
  protected
  def valid_id? name
    if name =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
      true
    else
      false
    end
  end
end