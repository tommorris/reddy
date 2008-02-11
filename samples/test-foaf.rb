#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'open-uri'

model = Rena::MemModel.new

# model.load("foaf.rdf",
#            :content_type => 'application/rdf+xml',
#            :base => URI.parse("http://web.sfc.keio.ac.jp/~s01397ms/foaf.rdf"))
model.load("http://tommorris.org/foaf")

#model.save(STDOUT, :content_type => 'application/rdf+xml')
model.save(STDOUT, :content_type => 'text/ntriples')
