class Literal
  attr_accessor :contents, :lang
  def initialize(contents, lang = nil)
    @contents = contents
    if lang != nil && lang != false
      @lang = lang.downcase
    end
  end
  
  def == (obj)
    if obj.class == Literal && obj.contents == @contents && (obj.lang == @lang || (obj.lang == nil && @lang == nil))
      true
    else
      false
    end
  end
  
  def to_n3
    out = "\"" + @contents + "\""
    out += "@" + @lang if @lang != nil
    out += "^^" + @encoding if @encoding != nil
    return out
  end
  
  def to_ntriples
    return self.to_n3
  end

  def to_trix
    if @lang != nil && @lang != false
      out = "<plainLiteral xml:lang=\"" + @lang + "\">"
    else
      out = "<plainLiteral>"
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