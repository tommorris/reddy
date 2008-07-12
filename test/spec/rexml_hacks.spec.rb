require 'lib/rena'
require 'rexml/document'
#require 'lib/rexml_hacks'

describe "REXML" do
  before do
    string = <<-EOF;
    <?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xml:lang="en" xml:base="http://example.org/">
      <rdf:Description>
        <foo>bar</foo>
      </rdf:Description>
    </rdf:RDF>
    EOF
    
    @doc = REXML::Document.new(string)
  end
  
  it "should have support for xml:base" do
    @doc.root.elements[1].base?.should == true
    @doc.root.elements[1].base.should == "http://example.org/"
  end
  
  it "should have support for xml:lang" do
    @doc.root.elements[1].lang?.should == true
    @doc.root.elements[1].lang.should == "en"
  end
end