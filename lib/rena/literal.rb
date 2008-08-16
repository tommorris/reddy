module Rena
  class Literal
    class Language
      attr_reader :value
      def self.coerce(string_or_nil)
        if string_or_nil.nil? || string_or_nil == ''
          the_null_language
        else
          new string_or_nil
        end
      end

      def self.the_null_language
        return @@the_null_language if defined? @@the_null_language
        @@the_null_language = Object.new
        class << @@the_null_language
          def to_s
            ''
          end

          alias_method :to_n3, :to_s
          alias_method :to_trix, :to_s

          def inspect
            "<Rena::Literal::Language:the_null_language>"
          end
        end
        return @@the_null_language
      end

      def initialize(string)
        @value = string.downcase
      end

      def to_s
        @value
      end

      def to_n3
        "@#{@value}"
      end

      def to_trix
        " xml:lang=\"#{@value}\""
      end

      def ==(other)
        case other
        when String
          other == @value
        else
          other.is_a?(self.class) && other.value == @value
        end
      end

      def hash
        @language.hash ^ self.class.hash
      end
    end

    attr_accessor :contents, :lang
    def initialize(contents, lang = nil)
      @contents = contents.to_s
      @lang = Language.coerce(lang)
    end

    def == (obj)
      obj.is_a?(self.class) && obj.contents == @contents && obj.lang == @lang
    end

    def to_n3
      "\"#{@contents}\"#{@lang.to_n3}"
    end

    ## alias_method breaks subclasses! Beware! Here be dragons!
    def to_ntriples
      to_n3
    end

    def to_trix
      out = "<plainLiteral#{@lang.to_trix}>"
      out += @contents
      out += "</plainLiteral>"
      return out
    end

  end

  class TypedLiteral < Literal
    LITERAL_ENCODING = "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
    INTEGER_ENCODING = "http://www.w3.org/2001/XMLSchema#int"
    FLOAT_ENCODING   = "http://www.w3.org/2001/XMLSchema#float"
    STRING_ENCODING  = "http://www.w3.org/2001/XMLSchema#string"

    attr_accessor :contents, :encoding
    def initialize(contents, encoding)
      @contents = contents
      @encoding = encoding
    end

    def == (obj)
      obj.class == self.class && obj.contents == @contents && obj.encoding == @encoding
    end

    def to_n3
      out = @encoding == INTEGER_ENCODING ? @contents.to_s : "\"#{@contents}\""
      out += "^^<" + @encoding + ">" if @encoding != nil
      return out
    end

    def to_trix
      "<typedLiteral datatype=\"#{@encoding}\">#{@contents}</typedLiteral>"
    end

    def xmlliteral?
      @encoding == LITERAL_ENCODING
    end

    def infer!
      @encoding =
        case @contents
        when Integer; INTEGER_ENCODING
        when Float;   FLOAT_ENCODING
        else          STRING_ENCODING
        end
    end
  end
end
