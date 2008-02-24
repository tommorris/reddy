class Literal
  attr_accessor :contents, :lang
  def initialize(contents, lang = nil)
    @contents = contents
    if lang != nil && lang != false
      @lang = lang.downcase
    end
  end
  
  def == (obj)
    if obj.class == Literal && obj.contents == @contents && (obj.lang == @lang || (obj.lang == nil && @lang == nil))
      true
    else
      false
    end
  end
  
  def to_n3
    out = "\"" + @contents + "\""
    out += "@" + @lang if @lang != nil
    out += "^^" + @encoding if @encoding != nil
    return out
  end
  
  def to_ntriples
    return self.to_n3
  end

  def to_trix
    if @lang != nil && @lang != false
      out = "<plainLiteral xml:lang=\"" + @lang + "\">"
    else
      out = "<plainLiteral>"
    end
    out += @contents
    out += "</plainLiteral>"
    return out
  end

end

class TypedLiteral < Literal
  attr_accessor :contents, :encoding
  def initialize(contents, encoding)
    @contents = contents
    @encoding = encoding
  end
  
  def == (obj)
    if obj.class == TypedLiteral && obj.contents == @contents && obj.encoding == @encoding
      return true
    else
      return false
    end
  end
  
  def to_n3
    out = "\"" + @contents + "\""
    out += "^^" + @encoding if @encoding != nil
    return out
  end
  
  def to_trix
    "<typedLiteral datatype=\"" + @encoding + "\">" + @contents + "</typedLiteral>"
  end
  
  # TODO: def infer!?
end

describe "Literals" do
  it "accept a language tag" do
    f = Literal.new("tom", "en")
    f.lang.should == "en"
  end
  
  it "accepts an encoding" do
    f = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.encoding.should == "http://www.w3.org/2001/XMLSchema#string"
  end
  
  it "should be equal if they have the same contents" do
    f = Literal.new("tom")
    g = Literal.new("tom")
    f.should == g    
  end
  
  it "should be equal if they have the same contents and language" do
    f = Literal.new("tom", "en")
    g = Literal.new("tom", "en")
    f.should == g
  end
  
  it "should be equal if they have the same contents, language and datatype" do
    f = Literal.new("tom", "en")
    g = Literal.new("tom", "en")
    f.should == g
    
    f2 = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g2 = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    f2.should == g2
  end
  
  it "should be equal if they have the same contents and datatype but no language" do
    f = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.should == g
  end
  
  it "should return valid N-* format strings" do
    f = Literal.new("tom")
    f.to_n3.should == "\"tom\""
    f.to_ntriples.should == f.to_n3
    
    g = Literal.new("tom", "en")
    g.to_n3.should == "\"tom\"@en"
    f.to_ntriples.should == f.to_n3
  end
  
  it "should normalize language tags to lower case" do
    f = Literal.new("tom", "EN")
    f.lang.should == "en"
  end
  
  it "should support TriX encoding" do
    f = Literal.new("tom", "en")
    f.to_trix.should == "<plainLiteral xml:lang=\"en\">tom</plainLiteral>"
    
    g = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g.to_trix.should == "<typedLiteral datatype=\"http://www.w3.org/2001/XMLSchema#string\">tom</typedLiteral>"
  end
end