# require 'lib/reddy'

module Rena
  class Rena::RdfaParser
    attr_accessor :xml, :uri, :graph

    def initialize (str, uri)
      @doc_string = str
      @xml = REXML::Document.new(str)
      @uri = uri
      @graph = Graph.new
      self.iterate(@xml.root.elements[2].elements[1].elements[1])
    end

    def parse_ns_curie(el, attname)
      attstring = el.attributes[attname]
      prefix = attstring.scan(/(.+):.+/).to_s
      if el.namespaces[prefix]
        namespace = el.namespaces[prefix]
      else
        raise "Namespace used in CURIE but not declared"
      end
      return namespace + attstring.scan(/.+:(.+)/).to_s
    end

    def iterate (el)

      if el.attributes['about']
        if el.attributes['about'] =~ /^http/
          # deal with as absolute
          subject = el.attributes['about'].to_s
        else
          # time to go xml:base sneakin'
          if xml.base?
            subject = Addressable::URI.parse(xml.base)
            subject = subject + el.attributes['about']
          else
            subject = Addressable::URI.parse(@uri)
            subject = subject + el.attributes['about']
          end
        end
      else
        subject = @uri
      end
  
      if el.attributes['property']
        if el.attributes['property'] =~ /^http/
          property = el.attributes['property']
        else
          # curie hunt!
        property = self.parse_ns_curie(el, "property")
        end
      end
  
      if el.attributes['content']
        value = el.attributes['content']
      else
        value = el.text
      end

      @graph.add_triple subject.to_s, URIRef.new(property), value
    end

  end
end