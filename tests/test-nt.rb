#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'test/unit'

class TestNT < Test::Unit::TestCase
  def test_nt
    model = Rena::MemModel.new
    assert_nothing_raised{
      model.load(File.join(File.dirname(__FILE__), "test.nt"),
                 :content_type => 'text/ntriples')
    }
  end
end
