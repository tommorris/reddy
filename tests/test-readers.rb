#!/usr/bin/env ruby
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'rena-test-utils'

require 'hyperset'
require 'test/unit'
require 'find'
require 'pp'

class TestReaders < Test::Unit::TestCase
  include RenaTestUtils

  def check_rdf(nt_fpath, rdf_fpath, check_warn=false)
    uri1 = URI.parse("http://www.w3.org/2000/10/rdf-tests/rdfcore/" +
                       nt_fpath.sub(/^.*approved_20031114\//, ''))
    uri2 = URI.parse("http://www.w3.org/2000/10/rdf-tests/rdfcore/" +
                       rdf_fpath.sub(/^.*approved_20031114\//, ''))

    is_warned = false

    model1 = Rena::MemModel.new
    model2 = Rena::MemModel.new

    model1.load(nt_fpath,
                :content_type => 'text/ntriples',
                :base => uri1)
    model2.load(rdf_fpath,
                :content_type => 'application/rdf+xml',
                :base => uri2,
                :warn => lambda{ is_warned = true })
    
    assert_equal(true, is_warned) if check_warn

    if model1.statements.size != model2.statements.size
      puts "--------------------------------"
      model1.statements.map{|s| p s.predicate }
      puts "--------------------------------"
      model2.statements.map{|s| p s.predicate }
      puts "--------------------------------"
    end

    assert_equal(model1.statements.size,
                 model2.statements.size,
                 "#{nt_fpath} and #{rdf_fpath} have different number of statements")

    s1 = model_to_hyperset(model1)
    s2 = model_to_hyperset(model2)

    # model2.save(STDOUT, :content_type=>'text/ntriples') if s1!=s2

    assert_equal(s1, s2,
                 "#{nt_fpath} and #{rdf_fpath} are not equal as hyperset")
  end

  def check_error(rdf_fpath)
    model = Rena::MemModel.new

    base = URI.parse("http://www.w3.org/2000/10/rdf-tests/rdfcore/" +
                       rdf_fpath.sub(/^.*approved_20031114\//, ''))

    assert_raise(Rena::LoadError){
      model.load(rdf_fpath,
                 :content_type => 'application/rdf+xml',
                 :base => base)
    }
  end


  base = File.join(File.dirname(__FILE__), "approved_20031114")
  Dir.entries(base).each{|e|
  #["rdf-containers-syntax-vs-schema"].each{|e|
  #["rdfms-xml-literal-namespaces"].each{|e|
    next if ["..", "."].member?(e)
    fname = File.join(base, e)
    next unless File.directory?(fname)

    Find.find(fname){|rdf_fpath|
      if m = %r!(.*/(test[^/]*))\.rdf$!.match(rdf_fpath) and
          File.exist?(nt_fpath = m[1] + ".nt")
        mname = "test_" + e.gsub(/-/, "_") + "__" + m[2].gsub(/-/, "_")
        define_method(mname.intern){||
          check_rdf(nt_fpath, rdf_fpath)
        }
      end
    }

    Find.find(fname){|rdf_fpath|
      if m = %r!(.*/(error[^/]*))\.rdf$!.match(rdf_fpath)
        mname = "test_" + e.gsub(/-/, "_") + "__" + m[2].gsub(/-/, "_")
        define_method(mname.intern){||
          check_error(rdf_fpath)
        }
      end
    }

    Find.find(fname){|rdf_fpath|
      if m = %r!(.*/(warn[^/]*))\.rdf$!.match(rdf_fpath) and
          File.exist?(nt_fpath = m[1] + ".nt")
        mname = "test_" + e.gsub(/-/, "_") + "__" + m[2].gsub(/-/, "_")
        define_method(mname.intern){||
          check_rdf(nt_fpath, rdf_fpath, true)
        }
      end
    }
  }

end
