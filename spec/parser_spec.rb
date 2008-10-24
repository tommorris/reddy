require 'lib/reddy'
require 'ruby-debug'
include Rena

# w3c test suite: http://www.w3.org/TR/rdf-testcases/

describe "RDF/XML Parser" do
  it "should recognise and do nothing for an RDF-less document" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
<NotRDF />
EOF
    graph = RdfXmlParser.new(sampledoc)
    graph.graph.size.should == 0
  end
  
  it "should trigger parsing on XMl documents with multiple RDF nodes" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
<GenericXML xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ex="http://example.org/">
  <rdf:RDF>
    <rdf:Description rdf:about="http://example.org/one">
      <ex:name>Foo</ex:name>
    </rdf:Description>
  </rdf:RDF>
  <blablabla />
  <rdf:RDF>
    <rdf:Description rdf:about="http://example.org/two">
      <ex:name>Bar</ex:name>
    </rdf:Description>
  </rdf:RDF>
</GenericXML>
    EOF
    graph = RdfXmlParser.new(sampledoc)
    [graph.graph[0].object.to_s, graph.graph[1].object.to_s].sort.should == ["Bar", "Foo"].sort
  end
  
  it "should be able to parse a simple single-triple document" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:ex="http://www.example.org/" xml:lang="en" xml:base="http://www.example.org/foo">
  <ex:Thing rdf:about="http://example.org/joe" ex:name="bar">
    <ex:belongsTo rdf:resource="http://tommorris.org/" />
    <ex:sampleText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">foo</ex:sampleText>
    <ex:hadADodgyRelationshipWith>
      <rdf:Description>
        <ex:name>Tom</ex:name>
        <ex:hadADodgyRelationshipWith>
          <rdf:Description>
            <ex:name>Rob</ex:name>
            <ex:hadADodgyRelationshipWith>
              <rdf:Description>
                <ex:name>Mary</ex:name>
              </rdf:Description>
            </ex:hadADodgyRelationshipWith>
          </rdf:Description>
        </ex:hadADodgyRelationshipWith>
      </rdf:Description>
    </ex:hadADodgyRelationshipWith>
  </ex:Thing>
</rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc)
    graph.graph.size.should == 10
    # print graph.graph.to_ntriples
    # TODO: add datatype parsing
    # TODO: make sure the BNode forging is done correctly - an internal element->nodeID mapping
    # TODO: proper test
  end
  
  it "should raise an error if rdf:aboutEach is used, as per the negative parser test rdfms-abouteach-error001 (rdf:aboutEach attribute)" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
  
      <rdf:Bag rdf:ID="node">
        <rdf:li rdf:resource="http://example.org/node2"/>
      </rdf:Bag>
  
      <rdf:Description rdf:aboutEach="#node">
        <dc:rights xmlns:dc="http://purl.org/dc/elements/1.1/">me</dc:rights>
  
      </rdf:Description>
  
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end
  
  it "should raise an error if rdf:aboutEachPrefix is used, as per the negative parser test rdfms-abouteach-error002 (rdf:aboutEachPrefix attribute)" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
  
      <rdf:Description rdf:about="http://example.org/node">
        <eg:property>foo</eg:property>
      </rdf:Description>
  
      <rdf:Description rdf:aboutEachPrefix="http://example.org/">
        <dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">me</dc:creator>
  
      </rdf:Description>
  
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end
  
  it "should fail if given a non-ID as an ID (as per rdfcore-rdfms-rdf-id-error001)" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
     <rdf:Description rdf:ID='333-555-666' />
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end
  
  it "should make sure that the value of rdf:ID attributes match the XML Name production (child-element version)" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
     <rdf:Description>
       <eg:prop rdf:ID="q:name" />
     </rdf:Description>
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end
  
  it "should be able to reify according to §2.17 of RDF/XML Syntax Specification" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:ex="http://example.org/stuff/1.0/"
             xml:base="http://example.org/triples/">
      <rdf:Description rdf:about="http://example.org/">
        <ex:prop rdf:ID="triple1">blah</ex:prop>
      </rdf:Description>
    </rdf:RDF>
    EOF

    graph = RdfXmlParser.new(sampledoc)
    graph.graph.size.should == 5
    graph.graph.to_ntriples.should == <<-EOF;
<http://example.org/> <http://example.org/stuff/1.0/prop> \"blah\" .
<http://example.org/triples/#triple1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
<http://example.org/triples/#triple1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/> .
<http://example.org/triples/#triple1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/stuff/1.0/prop> .
<http://example.org/triples/#triple1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> \"blah\" .
EOF
  end
  
  it "should make sure that the value of rdf:ID attributes match the XML Name production (data attribute version)" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
     <rdf:Description rdf:ID="a/b" eg:prop="val" />
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end
  
  it "should handle parseType=Literal according to xml-literal-namespaces-test001.rdf test" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
  
    <!--
      Copyright World Wide Web Consortium, (Massachusetts Institute of
      Technology, Institut National de Recherche en Informatique et en
      Automatique, Keio University).
  
      All Rights Reserved.
  
      Please see the full Copyright clause at
      <http://www.w3.org/Consortium/Legal/copyright-software.html>
  
      Description: Visibly used namespaces must be included in XML
             Literal values. Treatment of namespaces that are not 
             visibly used (e.g. rdf: in this example) is implementation
             dependent. Based on example from Issues List.
  
  
      $Id: test001.rdf,v 1.2 2002/11/22 13:52:15 jcarroll Exp $
  
    -->
    <rdf:RDF xmlns="http://www.w3.org/1999/xhtml"
       xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
       xmlns:html="http://NoHTML.example.org"
       xmlns:my="http://my.example.org/">
       <rdf:Description rdf:ID="John_Smith">
        <my:Name rdf:parseType="Literal">
          <html:h1>
            <b>John</b>
          </html:h1>
       </my:Name>
  
      </rdf:Description>
    </rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc, "http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test001.rdf")
    graph.graph.to_ntriples.should == "<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test001.rdf#John_Smith> <http://my.example.org/Name> \"<html:h1>\n            <b>John</b>\n          </html:h1>\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .\n"
  end

  it "should pass rdfms-syntax-incomplete-test001" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
  
     <rdf:Description rdf:nodeID="a">
       <eg:property rdf:nodeID="a" />
     </rdf:Description>
  
    </rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc)
    graph.graph.size.should == 1
  end
  
  it "should pass rdfms-syntax-incomplete-test002" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
  
    <!--
      Copyright World Wide Web Consortium, (Massachusetts Institute of
      Technology, Institut National de Recherche en Informatique et en
      Automatique, Keio University).
  
      All Rights Reserved.
  
      Please see the full Copyright clause at
      <http://www.w3.org/Consortium/Legal/copyright-software.html>
  
    -->
    <!--
  
      rdf:nodeID can be used to label a blank node.
      These have file scope and are distinct from any
      unlabelled blank nodes.
      $Id: test002.rdf,v 1.1 2002/07/30 09:46:05 jcarroll Exp $
  
    -->
  
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
  
     <rdf:Description rdf:nodeID="a">
       <eg:property1 rdf:nodeID="a" />
     </rdf:Description>
     <rdf:Description>
       <eg:property2>
  
    <!-- Note the rdf:nodeID="b" is redundant. -->
          <rdf:Description rdf:nodeID="b">
                <eg:property3 rdf:nodeID="a" />
          </rdf:Description>
       </eg:property2>
     </rdf:Description>
  
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should_not raise_error
  end
  
  it "should pass rdfms-syntax-incomplete/test003.rdf" do
    sampledoc = <<-EOF;
<?xml version="1.0"?>
  
    <!--
      Copyright World Wide Web Consortium, (Massachusetts Institute of
      Technology, Institut National de Recherche en Informatique et en
      Automatique, Keio University).
  
      All Rights Reserved.
  
      Please see the full Copyright clause at
      <http://www.w3.org/Consortium/Legal/copyright-software.html>
  
    -->
    <!--
  
      On an rdf:Description or typed node rdf:nodeID behaves
      similarly to an rdf:about.
      $Id: test003.rdf,v 1.2 2003/07/24 15:51:06 jcarroll Exp $
  
    -->
  
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:eg="http://example.org/">
  
     <!-- In this example the rdf:nodeID is redundant. -->
     <rdf:Description rdf:nodeID="a" eg:property1="value" />
  
    </rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc)
    graph.graph[0].subject.to_s.should == "a"
  end
  
  it "should be able to handle Bags/Alts etc." do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:eg="http://example.org/">
  <rdf:Bag>
    <rdf:li rdf:resource="http://tommorris.org/" />
    <rdf:li rdf:resource="http://twitter.com/tommorris" />
  </rdf:Bag>
</rdf:RDF>
    EOF
    graph = RdfXmlParser.new(sampledoc)
    graph.graph[1].predicate.to_s.should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#_1"
    graph.graph[2].predicate.to_s.should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#_2"
  end
  
  # # when we have decent Unicode support, add http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-rdf-id/error005.rdf
  # 
  # it "should support reification" do
  #   pending
  # end
  # 
  it "detect bad bagIDs" do
    sampledoc = <<-EOF;
<?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
     <rdf:Description rdf:bagID='333-555-666' />
    </rdf:RDF>
    EOF
    
    lambda do
      graph = RdfXmlParser.new(sampledoc)
    end.should raise_error
  end

 describe "parsing rdf files" do
   def test_file(filepath, uri = nil)
     n3_string = File.read(filepath)
     parser = RdfXmlParser.new(n3_string, uri)
     ntriples = parser.graph.to_ntriples
     ntriples.gsub!(/_:bn\d+/, '_:node1')
     ntriples = ntriples.split("\n").sort.join("\n")
     
     nt_string = File.read(filepath.sub('.rdf', '.nt'))
     nt_string = nt_string.split("\n").sort.join("\n")
     
     ntriples.should == nt_string
   end
   
   before(:all) do
     @rdf_dir = File.join(File.dirname(__FILE__), '..', 'test', 'rdf_tests')
   end
    
    it "should parse Coldplay's BBC Music profile" do
      gid = 'cc197bad-dc9c-440d-a5b5-d52ba2e14234'
      file = File.join(@rdf_dir, "#{gid}.rdf")
      test_file(file, "http://www.bbc.co.uk/music/artists/#{gid}")
    end
    
    # it "should parse xml literal test" do
    #   file = File.join(@rdf_dir, "xml-literal-mixed.rdf")
    #   test_file(file)
    # end
  end
end