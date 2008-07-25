require 'lib/rena'

describe "N3 parser" do

  # n3p tests taken from http://inamidst.com/n3p/test/
  describe "parsing n3p test" do
    dir_name = File.join(File.dirname(__FILE__), '..', 'n3_tests', 'n3p', '*.n3')
    Dir.glob(dir_name).each do |n3|    
      it n3 do
        test_file(n3)
      end
    end
  end
  
  describe "parsing misc tests" do
    dir_name = File.join(File.dirname(__FILE__), '..', 'n3_tests', 'misc', '*.n3')
    Dir.glob(dir_name).each do |n3|    
      it n3 do
        test_file(n3)
      end
    end
  end
    
  def test_file(filepath)
    n3_string = File.read(filepath)
    parser = N3Parser.new(n3_string)
    ntriples = parser.graph.to_ntriples
    ntriples.gsub!(/_:bn\d+/, '_:node1')
    ntriples = sort_ntriples(ntriples)
    
    nt_string = File.read(filepath.sub('.n3', '.nt'))
    nt_string = sort_ntriples(nt_string)

    ntriples.should == nt_string    
  end
  
  def sort_ntriples(string)
    string.split("\n").sort.join("\n")
  end

end