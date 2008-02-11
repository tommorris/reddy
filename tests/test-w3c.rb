#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'

def test (rdf, nt)
  begin
    rdfmodel = Rena::MemModel.new
    rdfmodel.load(open(rdf), :content_type => "application/rdf+xml")
  rescue
    print "rdf/xml whoopsie!\n"
  end

  begin
    ntmodel = Rena::MemModel.new
    ntmodel.load(open(nt), :content_type => "text/ntriples")
  rescue
    print "ntriples whoopse!\n"
  end

  if rdfmodel.to_ntriples == ntmodel.to_ntriples
    return true
  else
    return false
  end
end

def testboth(string)
  return test(string + ".rdf", string + ".nt").to_s
end

root = "approved_20031114/"
puts "amp-in-url 001: " + testboth(root + "amp-in-url/test001")
puts "datatypes 001: " + testboth(root + "datatypes/test001")
puts "datatypes 002: " + testboth(root + "datatypes/test002")