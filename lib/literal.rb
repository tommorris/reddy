class Literal
  attr_accessor :contents, :lang, :encoding
  def initialize(contents, lang = NULL, encoding = NULL)
    @contents = contents
    if lang != null
      @lang = lang
    end
    if encoding != null
      @encoding = encoding
    end
  end
end