require "test/unit"
require "lib/"

class TestRenaPerf < Test::Unit::TestCase
  def test_tom_foaf
    foaf = File.new("test/perf_test/tommorris.rdf", "r").readlines.join
    50.times do
      Rena::RdfXmlParser.new(foaf, "http://tommorris.org/foaf")
    end
  end
end