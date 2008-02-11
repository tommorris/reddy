#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

module Rena

#
# Parent class of Rena::PlainLiteral and Rena::TypedLiteral.
#
class Literal

  private

  begin
    # http://www.yoshidam.net/Ruby_ja.html
    require 'unicode'
    def _unicode_nfc(str)
      Unicode.normalize_C(str)
    end
  rescue LoadError
    def _unicode_nfc(str)
      str
    end
  end

  def initialize(str)
    str.unpack('U*')
    str = _unicode_nfc(str)
    @str = str
    @str.freeze
  end

  public

  #
  # returns string value.
  # 
  def string
    @str
  end

  def to_s
    @str
  end
  alias to_str to_s

  def nt
    '"' + NTriples.escape(@str) + '"'
  end
end # class Literal


# http://www.w3.org/TR/rdf-concepts/#dfn-plain-literal
class PlainLiteral < Literal
  def initialize(str, lang = nil)
    super(str)
    @lang = lang
    if @lang
      @lang.downcase
      @lang.freeze
    end
  end

  # returns a language tag as defined by [RFC-3066],
  # normalized to lowercase, or nil.
  attr_reader :lang

  def ==(other)
    equal?(other) or
      (PlainLiteral === other and
         to_s == other.to_s and
         @lang == other.lang)
  end

  def hash
    to_s.hash
  end
  def eql?(other)
    PlainLiteral === other and
      to_s.eql?(other.to_s) and
      @lang.eql?(other.lang)
  end

  def inspect
    nt
  end

  def nt
    s = super
    s << "@" + @lang if @lang 
    s
  end
end # class PlainLiteral


# http://www.w3.org/TR/rdf-concepts/#dfn-typed-literal
class TypedLiteral < Literal
  def initialize(str, type)
    super(str)
    @type = type
    @type.freeze
  end

  # returns <i>datatype URI</i>.
  attr_reader :type

  # returns <i>datatype URI</i>.
  alias datatype type

  def ==(other)
    equal?(other) or
      (TypedLiteral === other and
         to_s == other.to_s and
         @type == other.type)
  end

  def hash
    to_s.hash
  end
  def eql?(other)
    TypedLiteral === other and
      to_s.eql?(other.to_s) and
      @type.eql?(other.type)
  end

  def inspect
    nt
  end

  def nt
    s = super
    s << "^^<" + @type.to_s + ">" if @type
    s
  end
end # class TypedLiteral


end # module Rena
