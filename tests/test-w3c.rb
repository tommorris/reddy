#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'

def filename_to_contenttype (string)
  if string =~ /\S+\.rdf/
    format = "application/rdf+xml"
  end
  if string =~ /\S+\.nt/
    format = "text/ntriples"
  end
  return format
end

def test (root, expected, actual)
  begin
    expectedmodel = Rena::MemModel.new
    expectedmodel.load(open(root + expected), :content_type => filename_to_contenttype(root + expected))
  rescue
    print "parsing error on Expected file: " + root + expected + "\n"
  end

  begin
    actualmodel = Rena::MemModel.new
    actualmodel.load(open(root + actual), :content_type => filename_to_contenttype(root + actual))
  rescue
    print "parsing error on Actual file: " + root + actual + "\n"
  end

  if expectedmodel.to_ntriples == actualmodel.to_ntriples
    return true
  else
    puts "EXPECTED: " + expectedmodel.to_ntriples
    puts "ACTUAL: " + actualmodel.to_ntriples
    return false
  end
end

pre = "approved_20031114/"
puts "amp-in-url 001: " + test(pre + "amp-in-url/test001.", "rdf", "nt").to_s
puts "datatypes 001: " + test(pre + "datatypes/test001.", "rdf", "nt").to_s
puts "datatypes 002: " + test(pre + "datatypes/test002.", "rdf", "nt").to_s
puts "datatypes 003: " + test(pre + "datatypes/test003", "a.nt", "b.nt").to_s
puts "datatypes 005: " + test(pre + "datatypes/test005", "a.nt", "b.nt").to_s
puts "datatypes 008: " + test(pre + "datatypes/test008", "a.nt", "b.nt").to_s
puts "datatypes 009: " + test(pre + "datatypes/test009", "a.nt", "b.nt").to_s
puts "datatypes 011: " + test(pre + "datatypes/test011", "a.nt", "b.nt").to_s
puts "pfps-10 001: " + test(pre + "pfps-10/test001", "a.nt", "b.nt").to_s

# I decided that handling this manually is easier than parsing the RDF.
# I put two TextMate snippets to make entrance of these lines easier:
# rdt:
# puts "$1 $2: " + test(pre + "$1/test${2}$5.", "${3:rdf}", "${4:nt}").to_s
# rdtt:
# puts "$1 $2: " + test(pre + "$1/test${2}$5", "${3:a.nt}", "${4:b.nt}").to_s