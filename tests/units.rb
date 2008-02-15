#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'test/unit'

class TestTypedLiterals < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_literal
    string = Rena::TypedLiteral.new("hullo", "http://www.w3.org/2001/XMLSchema#string")
    assert_equal(string.to_s, "hullo")
    assert_equal(string.type, "http://www.w3.org/2001/XMLSchema#string")
    integer = Rena::TypedLiteral.new("01", "http://www.w3.org/2001/XMLSchema#int")
    assert_equal(integer.to_s, "1")
    assert_equal(integer.type, "http://www.w3.org/2001/XMLSchema#int")
  end
end