require 'lib/uriref'

class Namespace
  def initialize(uri, short)
    @uri = uri
    @short = short
  end
  
  def method_missing(methodname, *args)
    URIRef.new(@uri + methodname.to_s)
  end
end