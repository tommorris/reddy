require 'lib/rdfxmlparser'
describe "RDF/XML Parser" do
  it "should be able to detect whether an XML file is indeed an RDF file" do
    bad_doc = "<?xml version=\"1.0\"?><RDF><foo /></RDF>"
    bad_graph = RdfXmlParser.new(bad_doc)
    bad_graph.is_rdf?.should == false
    
    good_doc = "<?xml version=\"1.0\"?><rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"></rdf:RDF>"
    good_graph = RdfXmlParser.new(good_doc)
    good_graph.is_rdf?.should == true
  end
  
  it "should be able to parse a simple single-triple document" do
    sampledoc = <<-EOF;
    <?xml version="1.0" ?>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:ex="http://www.example.org/" xml:lang="en" xml:base="http://www.example.org/foo">
      <rdf:Description rdf:about="#" ex:name="bar">
        <ex:belongsTo rdf:resource="http://tommorris.org/" />
        <ex:sampleText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">foo</ex:sampleText>
        <ex:hadADodgyRelationshipWith rdf:parseType="Resource">
            <ex:name>Tom</ex:name>
        </ex:hadADodgyRelationshipWith>
      </rdf:Description>
    </rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc)
    graph.is_rdf?.should == true
    graph.graph.size == 6
#    print graph.graph.to_ntriples
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
  
  # when we have decent Unicode support, add http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-rdf-id/error005.rdf
  
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
end