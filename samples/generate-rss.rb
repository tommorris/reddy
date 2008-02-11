#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'rena/rdf'
require 'rena/dc'
require 'rena/rss'
include Rena

m = MemModel.new

channel = m.create_resource(URI.parse("http://www.tom.sfc.keio.ac.jp/%7Esakai/rss/sfc-media-center.rdf"))
channel.
  add_property(RDF::Type,  m.create_resource(RSS::Channel)).
  add_property(RSS::Title, PlainLiteral.new("メディアセンターニュース")).
  add_property(RSS::Link,  PlainLiteral.new("http://www.sfc.keio.ac.jp/mchtml/")).
  add_property(RSS::Description,
	       PlainLiteral.new("メディアセンターニュース"))

items = m.create_resource
channel.add_property(RSS::Items, items)
items.add_property(RDF::Type, m.create_resource(RDF::Seq))

item = m.create_resource(URI.parse("http://www.sfc.keio.ac.jp/mchtml/news/current_news.htm#14"))

items.add_property(URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#_1"),
		   item)

item.
  add_property(RDF::Type, m.create_resource(RSS::Item)).
  add_property(RSS::Link, PlainLiteral.new("http://www.sfc.keio.ac.jp/mchtml/news/current_news.htm#14")).
  add_property(RSS::Title, PlainLiteral.new("LEX/DB不具合発生中", "ja")).
  add_property(DC::Date, PlainLiteral.new("2004-02-10"))


m.save(STDOUT,
       :content_type => "application/rdf+xml",
       :charset => "shift_jis")
