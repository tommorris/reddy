# because Nokogiri, like all the other fucking XML parsers out there doesn't fucking under-fucking-stand
# the XML Namespaces spec, despite it being pretty fucking simple to understand for anyone who isn't a total
# shit fer brains.
module Nokogiri::XML
  class Attr
    def nsuri
      self.namespaces(self.namespace) || self.parent.namespaces(self.namespace)
    end
  end
end