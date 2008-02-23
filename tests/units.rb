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
    assert_equal string.to_s, "hullo"
    assert_equal string.type, "http://www.w3.org/2001/XMLSchema#string"
    integer = Rena::TypedLiteral.new("01", "http://www.w3.org/2001/XMLSchema#int")
    assert_equal integer.to_s, "1"
    assert_equal integer.type, "http://www.w3.org/2001/XMLSchema#int"
  end
  
  def test_amp_in_url
    # tests to see how ampersands in URLs are handled
    intest = Rena::MemModel.new
    intest.load("approved_20031114/amp-in-url/test001.rdf", :content_type => "application/rdf+xml")
    outtest = Rena::MemModel.new
    outtest.load("approved_20031114/amp-in-url/test001.nt", :content_type => "text/ntriples")
    assert_equal intest.to_ntriples, outtest.to_ntriples
  end
  
  def test_xsd_decimal_integer_compatible_datatypes_intensional
    # implements datatypes_intensional/test001.nt
    # rdfs:comment = The claim that xsd:integer is a subClassOF xsd:decimal 
    #      is not incompatible with using the intensional semantics for datatypes.
    assert_nothing_thrown do
      intest = Rena::MemModel.new
      intest.load("approved_20031114/datatypes-intensional/test001.nt", :content_type => "text/ntriples")
    end
  end
  
  def test_xsd_integer_string_incompatible_datatypes_intensional
    # implements datatypes_intensional/test002.nt
    # rdfs:comment = The claim that xsd:integer is a subClassOF xsd:string is
    #      incompatible with using the intensional semantics for datatypes.
    begin
      intest = Rena::MemModel.new
      intest.load("approved_20031114/datatypes-intensional/test002.nt", :content_type => "text/ntriples")
    rescue
      assert true, "Fails as expected"
    else
      flunk "This model should not pass!"
    end
  end
end