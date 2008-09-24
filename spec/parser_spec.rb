require 'lib/rena'
include Rena

# w3c test suite: http://www.w3.org/TR/rdf-testcases/

describe "RDF/XML Parser" do
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
    graph.graph.size == 6
    print graph.graph.to_ntriples
  end
  # 
  # it "should raise an error if rdf:aboutEach is used, as per the negative parser test rdfms-abouteach-error001 (rdf:aboutEach attribute)" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0" ?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  # 
  #     <rdf:Bag rdf:ID="node">
  #       <rdf:li rdf:resource="http://example.org/node2"/>
  #     </rdf:Bag>
  # 
  #     <rdf:Description rdf:aboutEach="#node">
  #       <dc:rights xmlns:dc="http://purl.org/dc/elements/1.1/">me</dc:rights>
  # 
  #     </rdf:Description>
  # 
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
  # 
  # it "should raise an error if rdf:aboutEachPrefix is used, as per the negative parser test rdfms-abouteach-error002 (rdf:aboutEachPrefix attribute)" do
  #   sampledoc = <<-EOF;
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  # 
  #     <rdf:Description rdf:about="http://example.org/node">
  #       <eg:property>foo</eg:property>
  #     </rdf:Description>
  # 
  #     <rdf:Description rdf:aboutEachPrefix="http://example.org/">
  #       <dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">me</dc:creator>
  # 
  #     </rdf:Description>
  # 
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
  # 
  # it "should fail if given a non-ID as an ID (as per rdfcore-rdfms-rdf-id-error001)" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0"?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  #    <rdf:Description rdf:ID='333-555-666' />
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
  # 
  # it "should make sure that the value of rdf:ID attributes match the XML Name production (child-element version)" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0" ?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  #    <rdf:Description>
  #      <eg:prop rdf:ID="q:name" />
  #    </rdf:Description>
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
  # 
  # it "should make sure that the value of rdf:ID attributes match the XML Name production (data attribute version)" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0" ?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  #    <rdf:Description rdf:ID="a/b" eg:prop="val" />
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
  # 
  # it "should handle parseType=Literal according to xml-literal-namespaces-test001.rdf test" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0"?>
  # 
  #   <!--
  #     Copyright World Wide Web Consortium, (Massachusetts Institute of
  #     Technology, Institut National de Recherche en Informatique et en
  #     Automatique, Keio University).
  # 
  #     All Rights Reserved.
  # 
  #     Please see the full Copyright clause at
  #     <http://www.w3.org/Consortium/Legal/copyright-software.html>
  # 
  #     Description: Visibly used namespaces must be included in XML
  #            Literal values. Treatment of namespaces that are not 
  #            visibly used (e.g. rdf: in this example) is implementation
  #            dependent. Based on example from Issues List.
  # 
  # 
  #     $Id: test001.rdf,v 1.2 2002/11/22 13:52:15 jcarroll Exp $
  # 
  #   -->
  #   <rdf:RDF xmlns="http://www.w3.org/1999/xhtml"
  #      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #      xmlns:html="http://NoHTML.example.org"
  #      xmlns:my="http://my.example.org/">
  #      <rdf:Description rdf:ID="John_Smith">
  #       <my:Name rdf:parseType="Literal">
  #         <html:h1>
  #           <b>John</b>
  #         </html:h1>
  #      </my:Name>
  # 
  #     </rdf:Description>
  #   </rdf:RDF>
  #   EOF
  #   
  #   graph = RdfXmlParser.new(sampledoc, "http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test001.rdf")
  #   graph.graph.to_ntriples.should == "<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test001.rdf#John_Smith> <http://my.example.org/Name> \"<html:h1>\n            <b>John</b>\n          </html:h1>\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .\n"
  # end
  # 
  # it "should pass rdfms-syntax-incomplete-test001" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0"?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  # 
  #    <rdf:Description rdf:nodeID="a">
  #      <eg:property rdf:nodeID="a" />
  #    </rdf:Description>
  # 
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should_not raise_error
  # end
  # 
  # it "should pass rdfms-syntax-incomplete-test002" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0"?>
  # 
  #   <!--
  #     Copyright World Wide Web Consortium, (Massachusetts Institute of
  #     Technology, Institut National de Recherche en Informatique et en
  #     Automatique, Keio University).
  # 
  #     All Rights Reserved.
  # 
  #     Please see the full Copyright clause at
  #     <http://www.w3.org/Consortium/Legal/copyright-software.html>
  # 
  #   -->
  #   <!--
  # 
  #     rdf:nodeID can be used to label a blank node.
  #     These have file scope and are distinct from any
  #     unlabelled blank nodes.
  #     $Id: test002.rdf,v 1.1 2002/07/30 09:46:05 jcarroll Exp $
  # 
  #   -->
  # 
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  # 
  #    <rdf:Description rdf:nodeID="a">
  #      <eg:property1 rdf:nodeID="a" />
  #    </rdf:Description>
  #    <rdf:Description>
  #      <eg:property2>
  # 
  #   <!-- Note the rdf:nodeID="b" is redundant. -->
  #         <rdf:Description rdf:nodeID="b">
  #               <eg:property3 rdf:nodeID="a" />
  #         </rdf:Description>
  #      </eg:property2>
  #    </rdf:Description>
  # 
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should_not raise_error
  # end
  # 
  # it "should pass rdfms-syntax-incomplete/test003.rdf" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0"?>
  # 
  #   <!--
  #     Copyright World Wide Web Consortium, (Massachusetts Institute of
  #     Technology, Institut National de Recherche en Informatique et en
  #     Automatique, Keio University).
  # 
  #     All Rights Reserved.
  # 
  #     Please see the full Copyright clause at
  #     <http://www.w3.org/Consortium/Legal/copyright-software.html>
  # 
  #   -->
  #   <!--
  # 
  #     On an rdf:Description or typed node rdf:nodeID behaves
  #     similarly to an rdf:about.
  #     $Id: test003.rdf,v 1.2 2003/07/24 15:51:06 jcarroll Exp $
  # 
  #   -->
  # 
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #            xmlns:eg="http://example.org/">
  # 
  #    <!-- In this example the rdf:nodeID is redundant. -->
  #    <rdf:Description rdf:nodeID="a" eg:property1="value" />
  # 
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should_not raise_error
  # end
  # 
  # # when we have decent Unicode support, add http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-rdf-id/error005.rdf
  # 
  # it "should support reification" do
  #   pending
  # end
  # 
  # it "detect bad bagIDs" do
  #   sampledoc = <<-EOF;
  #   <?xml version="1.0" ?>
  #   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  #    <rdf:Description rdf:bagID='333-555-666' />
  #   </rdf:RDF>
  #   EOF
  #   
  #   lambda do
  #     graph = RdfXmlParser.new(sampledoc)
  #   end.should raise_error
  # end
end
