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
    xmlns:ex="http://www.example.org/" xml:lang="en">
      <rdf:Description rdf:about="http://www.example.org/foo" ex:name="bar">
        <ex:belongsTo rdf:resource="http://tommorris.org/" />
        <ex:sampleText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">foo</ex:sampleText>
        <ex:hadADodgyRelationshipWith rdf:parseType="Literal">
          <ex:Person>
            <ex:name>Tom</ex:name>
          </ex:Person>
        </ex:hadADodgyRelationshipWith>
      </rdf:Description>
    </rdf:RDF>
    EOF
    
    graph = RdfXmlParser.new(sampledoc)
    graph.is_rdf?.should == true
    graph.graph.size == 6
#    print graph.graph.to_ntriples
  end
  
  it "should conform to the striping pattern" do
    pending
  end
end