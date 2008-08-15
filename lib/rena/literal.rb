module Rena
  class Literal
    class Language
      attr_reader :value
      def self.new(string_or_nil)
        if string_or_nil.nil? || string_or_nil == ''
          nil
        else
          super(string_or_nil)
        end
      end

      def initialize(string)
        @value = string.downcase
      end

      def to_s
        "@#{@value}"
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
      @lang = Language.new(lang)
    end

    def == (obj)
      obj.is_a?(self.class) && obj.contents == @contents && obj.lang == @lang
    end

    def to_n3
      out = "\"#{@contents}\""
      out += @lang.to_s
      out += "^^" + @encoding if @encoding
      return out
    end

    ## alias_method breaks subclasses! Beware! Here be dragons!
    def to_ntriples
      to_n3
    end

    def to_trix
      out = if @lang
              "<plainLiteral xml:lang=\"#{@lang.value}\">"
            else
              "<plainLiteral>"
            end
      out += @contents
      out += "</plainLiteral>"
      return out
    end

  end

  class TypedLiteral < Literal
    attr_accessor :contents, :encoding
    def initialize(contents, encoding)
      @contents = contents
      @encoding = encoding
      if @encoding == "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
        @xmlliteral = true
      else
        @xmlliteral = false
      end
    end

    def == (obj)
      if obj.class == TypedLiteral && obj.contents == @contents && obj.encoding == @encoding
        return true
      else
        return false
      end
    end

    def to_n3
      if @encoding == "http://www.w3.org/2001/XMLSchema#int"
        out = @contents.to_s
      else
        out = "\"" + @contents.to_s + "\""
      end
      out += "^^<" + @encoding + ">" if @encoding != nil
      return out
    end

    def to_trix
      "<typedLiteral datatype=\"" + @encoding + "\">" + @contents + "</typedLiteral>"
    end

    def xmlliteral?
      @xmlliteral
    end

    def infer!
      if @contents.class == Fixnum
        @encoding = "http://www.w3.org/2001/XMLSchema#int"
      elsif @contents.class == Float 
        @encoding = "http://www.w3.org/2001/XMLSchema#float"
      else
        @encoding = "http://www.w3.org/2001/XMLSchema#string"
      end
    end
  end
end
