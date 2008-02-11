#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require 'rena'
require 'open-uri'

class Writer
  def initialize(model, out)
    @model = model
    @out = out
    @table = Hash.new
    @counter = 0
  end

  def run
    @out.puts "digraph {"
    @model.each_resource{|subject|
      subject.each_property{|predicate,object|
        #next if predicate == Rena::RDF::Type
        @out.printf("\"%s\" -> \"%s\" [label=\"%s\"]\n",
                    escape(self[subject]),
                    escape(self[object]),
                    escape(predicate.to_s))
      }
    }
    @out.puts "}"
  end

  def escape(str)
    s = str.dup
    s.gsub!(/\\/,"\\\\")
    s.gsub!(/\n/, "\\n")
    s.gsub!(/\r/, "\\r")
    s.gsub!(/"/,  "\\\"")
    s
  end

  def [](x)
    if x.is_a? Rena::Literal
      if @table.key? x
        @table[x]
      else
        @table[x] = "hogehoge" + @counter.to_s
        @counter += 1
        @out.printf("%s [shape=box,label=\"%s\"];\n",
                    @table[x], escape(x.to_s))
        @table[x]
      end
    elsif x.uri
      x.uri.to_s
    else
      if @table.key? x
        @table[x]
      else
        @table[x] = "hogehoge" + @counter.to_s
        @counter += 1
        @out.printf("%s [shape=circle,label=\"\"];\n", @table[x])
        @table[x]
      end
    end
  end
end

if ARGV.empty?
  STDERR.puts "Usage:"
  STDERR.puts "   rdf2dot.rb [FILE] [Content-Type]"
  exit(1)
end

filename = ARGV.shift
params = Hash.new
params[:content_type] = ARGV.shift unless ARGV.empty?

model = Rena::MemModel.new
model.load(filename, params)

writer = Writer.new(model, STDOUT)
writer.run
