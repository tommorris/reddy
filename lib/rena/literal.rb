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

      def self.the_null_encoding
        return @@the_null_encoding if defined? @@the_null_encoding
        @@the_null_encoding = Object.new
        class << @@the_null_encoding
          def to_s
            ''
          end

          def format_as_n3(value)
            "\"#{value}\""
          end

          def format_as_trix(value)
            "<typedLiteral datatype=\"\">#{value}</typedLiteral>"
          end

          def inspect
            "<Rena::TypeLiteral::Encoding:the_null_encoding>"
          end

          def xmlliteral?
            false
          end
        end
        return @@the_null_encoding
      end

      attr_reader :url

      def initialize(url)
        @url = url
      end

      def should_quote?
        @url != self.class.integer.to_s
      end

      def ==(other)
        super ||
          case other
          when String
            other == @url
          when self.class
            other.url == @url
          else
            false
          end
      end

      def hash
        @url.hash
      end

      def to_s
        @url
      end

      def format_as_n3(value)
        quoted_value = should_quote? ? "\"#{value}\"" : value
        "#{quoted_value}^^<#{url}>"
      end

      def format_as_trix(value)
        "<typedLiteral datatype=\"#{@url}\">#{value}</typedLiteral>"
      end

      def xmlliteral?
        @url == "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
      end
    end

    attr_accessor :contents
    attr_reader :encoding
    def initialize(contents, encoding)
      @contents = contents
      @encoding = Encoding.coerce encoding
    end

    def encoding=(encoding)
      @encoding = Encoding.coerce(encoding)
    end

    def == (obj)
      obj.class == self.class && obj.contents == @contents && obj.encoding == @encoding
    end

    def to_n3
      @encoding.format_as_n3(@contents)
    end

    def to_trix
      @encoding.format_as_trix(@contents)
    end

    def xmlliteral?
      @encoding.xmlliteral?
    end

    def infer!
      @encoding =
        case @contents
        when Integer; Encoding.integer
        when Float;   Encoding.float
        else          Encoding.string
        end
    end
  end
end
