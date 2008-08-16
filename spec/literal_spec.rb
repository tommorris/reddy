require 'lib/rena'

describe "Literals" do
  it "accept a language tag" do
    f = Literal.new("tom", "en")
    f.lang.to_s.should == "en"
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
  
  it "should not be equal if they do not have the same contents" do
    f = Literal.new("tom")
    g = Literal.new("tim")
    f.should_not == g
  end
  
  it "should be equal if they have the same contents and language" do
    f = Literal.new("tom", "en")
    g = Literal.new("tom", "en")
    f.should == g
  end
  
  it "should not be equal if they do not have the same contents and language" do
    f = Literal.new("tom", "en")
    g = Literal.new("tim", "en")
    f.should_not == g
    
    lf = Literal.new("tom", "en")
    lg = Literal.new("tom", "fr")
    lf.should_not == lg
  end
  
  it "should be equal if they have the same contents and datatype" do
    f = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.should == g
  end

  it "should not be equal if they do not have the same contents and datatype" do
    f = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = TypedLiteral.new("tim", "http://www.w3.org/2001/XMLSchema#string")
    f.should_not == g

    dtf = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    dtg = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#token")
    dtf.should_not == dtg
  end
  
  it "should return valid N3/NTriples format strings" do
    f = Literal.new("tom")
    f.to_n3.should == "\"tom\""
    f.to_ntriples.should == f.to_n3
    
    g = Literal.new("tom", "en")
    g.to_n3.should == "\"tom\"@en"
    f.to_ntriples.should == f.to_n3
    
    typed_int = TypedLiteral.new(5, "http://www.w3.org/2001/XMLSchema#int")
    typed_int.to_n3.should == "5^^<http://www.w3.org/2001/XMLSchema#int>"
    typed_int.to_ntriples.should == typed_int.to_n3
    
    typed_string = TypedLiteral.new("foo", "http://www.w3.org/2001/XMLSchema#string")
    typed_string.to_n3.should == "\"foo\"^^<http://www.w3.org/2001/XMLSchema#string>"
    typed_string.to_ntriples.should == typed_string.to_n3
  end
  
  it "should normalize language tags to lower case" do
    f = Literal.new("tom", "EN")
    f.lang.should == "en"
  end
  
  it "should support TriX encoding" do
    e = Literal.new("tom")
    e.to_trix.should == "<plainLiteral>tom</plainLiteral>"
    
    f = Literal.new("tom", "en")
    f.to_trix.should == "<plainLiteral xml:lang=\"en\">tom</plainLiteral>"
    
    g = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g.to_trix.should == "<typedLiteral datatype=\"http://www.w3.org/2001/XMLSchema#string\">tom</typedLiteral>"
  end
  
  it "should handle XML litearls" do
    # first we should detect XML literals and mark them as such in the class
    f = TypedLiteral.new("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
    f.xmlliteral?.should == true
#    pending "TODO: the thought of XML literals makes me want to wretch"
  end
  
  it "should be able to infer!" do
    int = TypedLiteral.new(15, nil)
    int.infer!
    int.encoding.should == "http://www.w3.org/2001/XMLSchema#int"
    
    float = TypedLiteral.new(15.4, nil)
    float.infer!
    float.encoding.should == "http://www.w3.org/2001/XMLSchema#float"
    
    other = TypedLiteral.new("foo", nil)
    other.infer!
    other.encoding.should == "http://www.w3.org/2001/XMLSchema#string"
  end
end
