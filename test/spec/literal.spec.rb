require 'lib/literal.rb'

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
  
  it "should be equal if they have the same contents and datatype" do
    f = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = TypedLiteral.new("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.should == g
  end
  
  it "should return valid N3/NTriples format strings" do
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
  
  it "should handle XML litearls" do
    # first we should detect XML literals and mark them as such in the class
    f = TypedLiteral.new("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
    f.xmlliteral?.should == true
#    pending "TODO: the thought of XML literals makes me want to wretch"
  end
  
  it "should be able to detect XML literals" do
    f = Literal.new("foo <sup>bar</sup> baz!")
    f.infer!
  end
end