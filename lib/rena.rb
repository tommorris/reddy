#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#
require 'uri'
require 'set'

# XXX
a = URI.parse("http://ruby-lang.org/")
b = URI.parse("http://ruby-lang.org/")
unless a.eql?(b)
  class URI::Generic
    def hash
      component.inject(0){|result,item|
        result ^ (self.__send__(item).hash)
      }
    end

    def eql?(other)
      self==other
    end
  end
end


require 'rena/model'
require 'rena/xml'
require 'rena/nt'
require 'rena/memmodel'
