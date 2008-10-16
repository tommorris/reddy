require 'lib/rena'
include Rena

describe "N3 parser" do
  
  describe "parse simple ntriples" do
    n3_string = "<http://example.org/> <http://xmlns.com/foaf/0.1/name> \"Tom Morris\" . "
    parser = N3Parser.new(n3_string)
    parser.graph[0].subject.to_s.should == "http://example.org/"
    parser.graph[0].predicate.to_s.should == "http://xmlns.com/foaf/0.1/name"
    parser.graph[0].object.to_s.should == "Tom Morris"
    parser.graph.size.should == 1
  end
  
  # n3p tests taken from http://inamidst.com/n3p/test/
  describe "parsing n3p test" do
   dir_name = File.join(File.dirname(__FILE__), '..', 'test', 'n3_tests', 'n3p', '*.n3')
    Dir.glob(dir_name).each do |n3|    
      it n3 do
        test_file(n3)
      end
    end
  end
  
  describe "parsing real data tests" do
    dirs = [ 'misc', 'lcsh' ]
    dirs.each do |dir|
      dir_name = File.join(File.dirname(__FILE__), '..', 'test', 'n3_tests', dir, '*.n3')
      Dir.glob(dir_name).each do |n3|
        it "#{dir} #{n3}" do
          test_file(n3)
        end
      end
    end
  end
  
  it "should throw an exception when presented with a BNode as a predicate" do
    n3doc = "_:a _:b _:c ."
    lambda do parser = N3Parser.new(n3doc) end.should raise_error(Rena::Triple::InvalidPredicate)
  end

  it "should create BNodes" do
    n3doc = "_:a a _:c ."
    parser = N3Parser.new(n3doc)
    parser.graph[0].subject.class.should == Rena::BNode
    parser.graph[0].object.class.should == Rena::BNode
  end
  
  it "should create URIRefs" do
    n3doc = "<http://example.org/joe> <http://xmlns.com/foaf/0.1/knows> <http://example.org/jane> ."
    parser = N3Parser.new(n3doc)
    parser.graph[0].subject.class.should == Rena::URIRef
    parser.graph[0].object.class.should == Rena::URIRef
  end
  
  it "should create literals" do
    n3doc = "<http://example.org/joe> <http://xmlns.com/foaf/0.1/name> \"Joe\"."
    parser = N3Parser.new(n3doc)
    parser.graph[0].object.class.should == Rena::Literal
  end
  
  it "should create typed literals" do
    # n3doc = "<http://example.org/joe> <http://xmlns.com/foaf/0.1/name> \"Joe\"^^<http://www.w3.org/2001/XMLSchema#string> ."
    # parser = N3Parser.new(n3doc)
    # parser.graph[0].object.classs.should == Rena::Literal
    pending
  end

  def test_file(filepath)
    n3_string = File.read(filepath)
    parser = N3Parser.new(n3_string)
    ntriples = parser.graph.to_ntriples
    ntriples.gsub!(/_\:bn[\d|\-]+/, '_:node1')
    ntriples = sort_ntriples(ntriples)

    nt_string = File.read(filepath.sub('.n3', '.nt'))
    nt_string = sort_ntriples(nt_string)

    ntriples.should == nt_string    
  end
  
  def sort_ntriples(string)
    string.split("\n").sort.join("\n")
  end

end
