#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'rena/rdql'
require 'test/unit'
require 'pp'

class TestRDQL < Test::Unit::TestCase

  def test_hoge
    # Query example 1: Retrieve the value of a known property of a known resource
    assert_nothing_raised {
      parser = Rena::RDQL::Parser.new
      pp parser.parse <<END
      SELECT ?x
      WHERE  (<http://somewhere/res1>, <http://somewhere/pred1>, ?x)
END
    }

    # Query example 2: constraints
    assert_nothing_raised {
      parser = Rena::RDQL::Parser.new
      pp parser.parse <<END
      SELECT ?a, ?b
      WHERE  (?a, <http://somewhere/pred1>, ?b)
      AND    ?b < 5
END
    }

    # Query example 3: paths in the graph
    assert_nothing_raised {
      parser = Rena::RDQL::Parser.new
      pp parser.parse <<END
      SELECT ?a, ?b
      WHERE (?a, <http://somewhere/pred1>, ?c) ,
            (?c, <http://somewhere/pred2>, ?b)
END
    }

    # Query example 3: paths in the graph
    assert_nothing_raised {
      parser = Rena::RDQL::Parser.new
      pp parser.parse <<END
      SELECT ?x, ?y
      WHERE (<http://never/bag>, ?x, ?y)
      AND ! ( ?x eq <rsyn:type> && ?y eq <rsyn:Bag>)
      USING rsyn FOR <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
END
    }
  
  end
end
