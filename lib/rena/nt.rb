# -*- coding: utf-8 -*-
#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

module Rena
module NTriples

def escape(str)
  s = str.dup
  s.gsub!(/\\/, "\\\\")
  s.gsub!(/"/, "\\\"")
  s.gsub!(/\n/, "\\n")
  s.gsub!(/\r/, "\\r")
  s.gsub!(/\t/, "\\t")

  unicodes = s.unpack("U*")
  s = ''
  unicodes.each{|c|
    if 0x20 <= c and c <= 0x7E
      s.concat(format("%c",c))
    else
      s.concat(format("\\u%04X",c))
    end
  }

  s
end
module_function :escape

def unescape(str)
  str.gsub(/\\([^u]|u([0-9a-fA-F]{4}))/){
    case $1
    when "\\"
    when '"'
      $1
    when "n"
      "\n"
    when "r"
      "\r"
    when "t"
      "\t"
    else
      if $2
        [$2.hex].pack("U")
      else
        raise RuntimeError.new("\\#{$1} is invalid escape")
      end
    end
  }    
end
module_function :unescape


class Reader
  def initialize
    @model = nil
    @blank_nodes = {}
  end
  attr_accessor :model

  def read(io, params)
    io.each_line("\n"){|line|
      line.split(/\r/).each{|line2|
        parse_line(line2)
      }
    }
  end

  private
  def lookup_nodeID(nodeID)
    @blank_nodes[nodeID] ||= @model.create_resource
  end

  def parse_line(line)
      return if /\A\s*#/ =~ line
      return if /\A\s*\Z/ =~ line

      if line.sub!(/\A\s*<([^>]*)>/, '')
        subject = @model.create_resource(parse_uri($1))
      elsif line.sub!(/\A\s*_:([A-Za-z][A-Za-z0-9]*)/, '')
        subject = lookup_nodeID($1)
      else
        raise LoadError.new(line.inspect)
      end

      if line.sub!(/\A\s*<([^>]*)>/, '')
        predicate = parse_uri($1)
      else
        raise LoadError.new(line.inspect)
      end

      if line.sub!(/\A\s*<([^>]*)>/, '')
        object = @model.create_resource(parse_uri($1))
      elsif line.sub!(/\A\s*_:([A-Za-z][A-Za-z0-9]*)/, '')
        object = lookup_nodeID($1)
      elsif line.sub!(/\A\s*"((?:\\"|[^"])*)"(?:@([a-zA-Z_\-]*))?(?:\^\^<([^>]*)>)?/, '')
        str  = $1
        lang = $2
        type = $3
        str = NTriples.unescape(str)

        if type
          object = TypedLiteral.new(str, parse_uri(type))
        else
          object = PlainLiteral.new(str, lang)
        end
      else
        raise LoadError.new(line.inspect)
      end

      unless /\A\s*\.\s*\Z/ =~ line
        raise LoadError.new(line.inspect)
      end

      subject.add_property(predicate, object)
  end

  def parse_uri(s)
    URI.parse(NTriples.unescape(s))
  end
end # class Reader



class Writer

  def write(io, m, params)
    self.class.write_model(m, io)
  end

  def model2nt(m)
    require 'stringio'
    io = StringIO.new
    self.class.write_model(m, io)
    io.string
  end

  def self.write_model(m, io)
    blank_node_counter = 0
    blank_nodes_to_id = Hash.new
    resource_to_nt = lambda{|resource|
      if resource.uri
        '<' + NTriples.escape(resource.uri.to_s) + '>'
      else
        "_:" + (blank_nodes_to_id[resource] ||= "a" + (blank_node_counter += 1).to_s)
      end
    }

    m.each_resource{|subject|
      subject_str = resource_to_nt[subject]
      subject.each_property{|prop, object|
        io.print subject_str
        io.print " "
        io.print("<", NTriples.escape(prop.to_s), ">")
        io.print " "
        if object.is_a? Literal
          io.print object.nt
        else
          io.print resource_to_nt[object]
        end
        io.print " .\n"
      }
    }

    nil
  end
end # class Writer


end #module NTriples
end #module Rena
