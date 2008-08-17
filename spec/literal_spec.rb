require 'lib/rena'

describe "Literals" do
  it "accept a language tag" do
    f = Literal.untyped("tom", "en")
    f.lang.should == "en"
  end
  
  it "accepts an encoding" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.encoding.to_s.should == "http://www.w3.org/2001/XMLSchema#string"
  end
  
  it "should be equal if they have the same contents" do
    f = Literal.untyped("tom")
    g = Literal.untyped("tom")
    f.should == g    
  end
  
  it "should not be equal if they do not have the same contents" do
    f = Literal.untyped("tom")
    g = Literal.untyped("tim")
    f.should_not == g
  end
  
  it "should be equal if they have the same contents and language" do
    f = Literal.untyped("tom", "en")
    g = Literal.untyped("tom", "en")
    f.should == g
  end
  
  it "should not be equal if they do not have the same contents and language" do
    f = Literal.untyped("tom", "en")
    g = Literal.untyped("tim", "en")
    f.should_not == g
    
    lf = Literal.untyped("tom", "en")
    lg = Literal.untyped("tom", "fr")
    lf.should_not == lg
  end
  
  it "should be equal if they have the same contents and datatype" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.should == g
  end

  it "should not be equal if they do not have the same contents and datatype" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = Literal.typed("tim", "http://www.w3.org/2001/XMLSchema#string")
    f.should_not == g

    dtf = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    dtg = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#token")
    dtf.should_not == dtg
  end
  
  it "should return valid N3/NTriples format strings" do
    f = Literal.untyped("tom")
    f.to_n3.should == "\"tom\""
    f.to_ntriples.should == f.to_n3
    
    g = Literal.untyped("tom", "en")
    g.to_n3.should == "\"tom\"@en"
    f.to_ntriples.should == f.to_n3
    
    typed_int = Literal.typed(5, "http://www.w3.org/2001/XMLSchema#int")
    typed_int.to_n3.should == "5^^<http://www.w3.org/2001/XMLSchema#int>"
    typed_int.to_ntriples.should == typed_int.to_n3
    
    typed_string = Literal.typed("foo", "http://www.w3.org/2001/XMLSchema#string")
    typed_string.to_n3.should == "\"foo\"^^<http://www.w3.org/2001/XMLSchema#string>"
    typed_string.to_ntriples.should == typed_string.to_n3
  end
  
  it "should normalize language tags to lower case" do
    f = Literal.untyped("tom", "EN")
    f.lang.should == "en"
  end
  
  it "should support TriX encoding" do
    e = Literal.untyped("tom")
    e.to_trix.should == "<plainLiteral>tom</plainLiteral>"
    
    f = Literal.untyped("tom", "en")
    f.to_trix.should == "<plainLiteral xml:lang=\"en\">tom</plainLiteral>"
    
    g = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g.to_trix.should == "<typedLiteral datatype=\"http://www.w3.org/2001/XMLSchema#string\">tom</typedLiteral>"
  end
  
  it "should handle XML litearls" do
    # first we should detect XML literals and mark them as such in the class
    f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
    f.xmlliteral?.should == true
#    pending "TODO: the thought of XML literals makes me want to wretch"
  end

  it "build_from should infer the type" do
    int = Literal.build_from(15)
    int.encoding.should == "http://www.w3.org/2001/XMLSchema#int"
    
    float = Literal.build_from(15.4)
    float.encoding.should == "http://www.w3.org/2001/XMLSchema#float"
    
    other = Literal.build_from("foo")
    other.encoding.should == "http://www.w3.org/2001/XMLSchema#string"
  end
end
