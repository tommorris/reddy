require 'lib/uriref'

class Namespace
  def initialize(uri, short)
    @uri = uri
    if shortname_valid?(short)
      @short = short
    else
      raise
    end
  end
  
  def method_missing(methodname, *args)
    URIRef.new(@uri + methodname.to_s)
  end
  
  private
  def shortname_valid?(shortname)
    if shortname =~ /[a-zA-Z_][a-zA-Z0-9_]+/
      return true
    else
      return false
    end
  end
end