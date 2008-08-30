module Rena
  class Literal
    class Encoding
      def self.integer
        @integer ||= coerce "http://www.w3.org/2001/XMLSchema#int"
      end

      def self.float
        @float ||= coerce "http://www.w3.org/2001/XMLSchema#float"
      end

      def self.string
        @string ||= coerce "http://www.w3.org/2001/XMLSchema#string"
      end

      def self.coerce(string_or_nil)
        if string_or_nil.nil? || string_or_nil == ''
          the_null_encoding
        else
          new string_or_nil
        end
      end

      class Null
        def to_s
          ''
        end

        def format_as_n3(content)
          "\"#{content}\""
        end

        def format_as_trix(content)
          "<plainLiteral>#{content}</plainLiteral>"
        end

        def inspect
          "<theRena::TypeLiteral::Encoding::Null>"
        end

        def xmlliteral?
          false
        end
      end

      def self.the_null_encoding
        @the_null_encoding ||= Null.new
      end

      attr_reader :value
      def initialize(value)
        @value = value
      end

      def should_quote?
        @value != self.class.integer.to_s
      end

      def ==(other)
        case other
        when String
          other == @value
        when self.class
          other.value == @value
        else
          false
        end
      end

      def hash
        @value.hash
      end

      def to_s
        @value
      end

      def format_as_n3(content)
        quoted_content = should_quote? ? "\"#{content}\"" : content
        "#{quoted_content}^^<#{value}>"
      end

      def format_as_trix(value)
        "<typedLiteral datatype=\"#{@value}\">#{value}</typedLiteral>"
      end

      def xmlliteral?
        @value == "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
      end
    end

    class Language < Encoding
      def initialize(string)
        @value = string.downcase
      end

      def clean(string)
        case string
        when "eng"; "en"
        else string
        end
      end

      def format_as_n3(contents)
        "\"#{contents}\"@#{@value}"
      end

      def format_as_trix(contents)
        "<plainLiteral xml:lang=\"#{@value}\">#{contents}</plainLiteral>"
      end
      
      def == (other)
        case other
        when String
          other == @value
        when self.class
          other.value == @value
        end
      end
    end

    attr_accessor :contents, :encoding
    def initialize(contents, encoding)
      @contents = contents.to_s
      unless encoding.is_a?(Encoding) || encoding.is_a?(Encoding::Null)
        raise TypeError, "#{encoding.inspect} should be an instance of Encoding"
      end
      @encoding = encoding
    end

    def self.untyped(contents, language = nil)
      new(contents, Language.coerce(language))
    end

    def self.typed(contents, encoding)
      new(contents, Encoding.coerce(encoding))
    end

    def self.build_from(object)
      new(object.to_s, infer_encoding_for(object))
    end

    def self.infer_encoding_for(object)
      case object
      when Integer; Encoding.integer
      when Float;   Encoding.float
      else          Encoding.string
      end
    end

    require 'whatlanguage'
    unless WhatLanguage.nil?
      def self.infer_language_for(object)
        inferred_lang = object.language
        case inferred_lang
        when :dutch; Language.new("nl")
        when :english; Language.new("en")
        when :farsi; Langauge.new("fa")
        when :french; Language.new("fr")
        when :german; Language.new("de")
        when :pinyin; Language.new("zh-CN")
        when :portugese; Language.new("pt")
        when :russian; Language.new("ru")
        when :spanish; Language.new("es")
        when :swedish; Language.new("sv")
        end
      end
      
      def self.build_from_language(object)
        new(object.to_s, infer_language_for(object))
      end
    end

    class << self
      protected :new
    end

    def == (obj)
      obj.is_a?(self.class) && obj.contents == @contents && obj.encoding == @encoding
    end

    def to_n3
      encoding.format_as_n3(@contents)
    end

    ## alias_method breaks subclasses! Beware! Here be dragons!
    def to_ntriples
      to_n3
    end

    def to_trix
      encoding.format_as_trix(@contents)
    end

    def xmlliteral?
      encoding.xmlliteral?
    end

    def lang
      encoding.is_a?(Language) ? encoding : nil
    end
  end
end
