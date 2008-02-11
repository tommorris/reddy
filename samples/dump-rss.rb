#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'pp'
require 'open-uri'
require 'rena'
require 'rena/rss'
require 'rena/dc'
RDF = Rena::RDF
RSS = Rena::RSS
DC  = Rena::DC

model = Rena::MemModel.new

if ARGV.empty?
  ARGV.unshift "http://www.tom.sfc.keio.ac.jp/~sakai/rss/sfc-media-center.rdf"
  ARGV.unshift "http://www.tom.sfc.keio.ac.jp/~sakai/rss/sfc-itc.rdf"
  ARGV.unshift "http://www.sfc.keio.ac.jp/students_soukan/news/rss10.rss"
end

ARGV.each{|fname|
  model.load(fname, :content_type => "application/rdf+xml")
}

channel = model.lookup_resource(RSS::Channel)

model.each_resource{|res|
  next unless res.have_property?(RDF::Type, channel)

  items = res.get_property(RSS::Items)
  next unless items

  items.each_property{|prop, item|
    next unless %r!\Ahttp://www.w3.org/1999/02/22-rdf-syntax-ns#_(\d+)\Z! =~ prop.to_s
    puts "--"
    puts item.get_property(RSS::Link)
    puts item.get_property(RSS::Title)
    puts item.get_property(DC::Date)
  }
}
