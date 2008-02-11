# -*- coding: utf-8 -*-
#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

require 'rena/rdql-parser'

module Rena
module RDQL

class Query
  def initialize(select, source, patterns, constraints, prefixes)
    @select      = select
    @source      = source
    @patterns    = patterns
    @constraints = constraints
    @prefixes    = prefixes
  end

  attr_accessor :select
  attr_accessor :source
  attr_accessor :patterns
  attr_accessor :constraints
  attr_accessor :prefixes

  def exec(model = nil)
    if model.nil?
      model = MemModel.new
      model.load(@source)
    end

    f = lambda{|i,binding|
      if i < patterns.size
        pattern = patterns[i]

        model.each_statement{|stmt|
          if new_binding = pattern.match(binding, stmt)
            f.call(i+1, new_binding)
          end
        }
      else
        # constraintをチェック
        yield binding
      end
    }

    nil
  end
end # class Query


class TriplePattern
  def initialize(subject, predicate, object)
    @subject   = subject
    @predicate = predicate
    @object    = object
  end

  def match(binding, stmt)
    new_binding = binding.dup

    if Symbol === @subject
      if x = new_binding[@subject]
        if ::URI === x
          return false unless x == stmt.subject.uri
        else
          return false unless x == stmt.subject
        end
      else
        new_binding[@subject] = stmt.subject
      end
    else
      return false unless @subject == stmt.subject.uri
    end

    if Symbol === @predicate
      if x = new_binding[@predicate]
        if ::URI === x
          return false unless x == stmt.predicate
        else
          return false unless x.uri == stmt.predicate
        end
      else
        new_binding[@predicate] = stmt.predicate
      end
    else
      return false unless @predicate == stmt.predicate
    end

    if Symbol === @object
      if x = new_binding[@object]
        if ::URI === x
          return false unless x == stmt.object.uri
        else
          return false unless x == stmt.object
        end
      else
        new_binding[@object] = stmt.object
      end
    else
      return false unless @object == stmt.object or
        (Rena::Resource === stmt.object and @object == stmt.object.uri)
    end

    new_binding
  end
end



class ConditionalAnd
  def initialize(*args)
    @args = args
  end
  attr_accessor :args

  def eval(binding)
    @args.inject(true){|result,item|
      result and item.eval(binding)
    }
  end
end

class ConditionalOr
  def initialize(*args)
    @args = args
  end
  attr_accessor :args

  def eval(binding)
    @args.inject(false){|result,item|
      result or item.eval(binding)
    }
  end
end


class StringEqual
  def initialize(a,b)
    @a = a
    @b = b
  end

  def eval(binding)
    @a.eval(binding) == @b.eval(binding)
  end
end

class StringNotEqual
  def initialize(a,b)
    @a = a
    @b = b
  end

  def eval(binding)
    @a.eval(binding) == @b.eval(binding)
  end
end


class BitOR
  def initialize(*args)
    @args = args
  end
  attr_accessor :args

  def eval(binding)
    @args.inject(0){|result,item|
      result || item.eval(binding)
    }
  end
end

class BitXOR
  def initialize(*args)
    @args = args
  end
  attr_accessor :args

  def eval(binding)
    @args.inject(0){|result,item|
      result ^ item.eval(binding)
    }
  end
end

class BitAND
  def initialize(*args)
    @args = args
  end
  attr_accessor :args

  def eval(binding)
    @args.inject(0){|result,item|
      result & item.eval(binding)
    }
  end
end


class EqualityExpression
end

class Eq < EqualityExpression
  def initialize(a,b)
    @a = a
    @b = b
  end
end

class NEq < EqualityExpression
  def initialize(a,b)
    @a = a
    @b = b
  end
end


class RelationalExpression
end

class BinaryRel < RelationalExpression
  def initialize(rel,a,b)
    @rel = rel
    @a = a
    @b = b
  end
end


class UnaryOp
  def initialize(op,a)
    @op = op
    @a = a
  end
end

class BinaryOp
  def initialize(op,a,b)
    @op = op
    @a = a
    @b = b
  end
end


end #RDQL
end #Rena

