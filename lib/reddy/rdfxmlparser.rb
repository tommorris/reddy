#require 'ruby-debug'
require 'nokogiri'
include Reddy

module Reddy
  
  class RdfXmlParser

    attr_accessor :xml, :graph
    def initialize(xml_str, uri = nil)
      @@syntax_base = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      @@rdf_type = @@syntax_base + "type"
      @excl = ["http://www.w3.org/1999/02/22-rdf-syntax-ns#resource",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#about",
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#ID"]
      @uri = Addressable::URI.parse(uri).to_s unless uri.nil?
      @graph = Reddy::Graph.new
	  @xml = Nokogiri::XML.parse(xml_str, uri)
      @id_mapping = Hash.new
      root = @xml.root
	  @xml.xpath("rdf:RDF/*", 'rdf' => @@syntax_base).collect {|el| parse_descriptions(el) }
    end
  
    private
    def parse_descriptions(el, subject=nil)
      # subject
      subject = parse_subject(el) if subject.nil?
      # class and container classes
      # following commented out - if we decide that special Container handling is required, we can do it here.
      # until then, the procedure I'm using is simple: checking for rdf:li elements when handling children
      # case [el.namespaces[["xmlns", el.namespace].join(":")], el.name]
      # when [@@syntax_base, "Bag"]
      # when [@@syntax_base, "Seq"]
      # when [@@syntax_base, "Alt"]
      # when [@@syntax_base, "Description"]
      # #when [@@syntax_base, "Statement"]
      # #when [@@syntax_base, "Container"] - from my reading of RDFS 1.0 (2004)
      # #§5.1.1, we should not expect to find Containers inside public documents.
      # else
      #   @graph.add_triple(subject, @@rdf_type, url_helper(el.name, el.namespaces[["xmlns", el.namespace].join(":")], el.base_uri))
      # end
      # If we ever decide to do special handling for OWL, here's where we can shove it. If. --tom
      unless el.name == "Description" && el.namespaces[["xmlns", el.namespace].join(":")] == @@syntax_base
        @graph.add_triple(subject, @@rdf_type, url_helper(el.name, el.namespaces[["xmlns", el.namespace].join(":")], el.base_uri))
      end

      # read each attribute that's not in @@syntax_base 
      el.attributes.each { |att|
        @graph.add_triple(subject, url_helper(att.name, att.ns.href, el.base_uri), att.value) unless att.ns.href == @@syntax_base
      }
      li_counter = 0 # this will increase for each li we iterate through
      el.each {|child|
        predicate = url_helper(child.name, child.namespaces[["xmlns", el.namespace].join(":")], child.base_uri)
        if predicate.to_s == @@syntax_base + "li"
          li_counter += 1
          predicate = Addressable::URI.parse(predicate.to_s)
          predicate.fragment = "_#{li_counter.to_s}"
          predicate = predicate.to_s
        end
        object = child.content
        if el.attribute_with_ns("nodeID", @@syntax_base)
          @graph.add_triple(subject, predicate, forge_bnode_from_string(child.attribute_with_ns("nodeID", @@syntax_base)))
        elsif child.attribute_with_ns("resource", @@syntax_base)
          @graph.add_triple(subject, predicate, URIRef.new(base_helper(child.attribute_with_ns("resource", @@syntax_base), child.base_uri).to_s))
        end
        child.each {|contents|
          if contents.text? and contents.content.strip.length != 0
            object = contents.content
            @graph.add_triple(subject, predicate, object)
          end
        }
        child.each {|cel|
          object = parse_subject(cel)
          if child.attribute_with_ns("parseType", @@syntax_base)
            case child.attribute_with_ns("parseType", @@syntax_base)
            when "XMLLiteral"
              object = Literal.typed(cel.namespaced_to_s, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
              @graph.add_triple(subject, predicate, object)
            when "Literal"
              if smells_like_xml?(cel.namespaced_to_s)
                object = Literal.typed(cel.to_s, "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
                @graph.add_triple(subject, predicate, object)
              else
                object = cel.to_s
                @graph.add_triple(subject, predicate, object)
              end
            when "Resource"
              object = BNode.new
              @graph.add_triple(subject, predicate, object)
              parse_descriptions(cel, object)
            #when "Collection";
            end
          else
            @graph.add_triple(subject, predicate, object)
            parse_descriptions(cel)
          end
        }
        
        # reification
        if child.attribute_with_ns("ID", @@syntax_base)
          if id_check?(child.attribute_with_ns("ID", @@syntax_base))
            rsubject = url_helper("#" + child.attribute_with_ns("ID", @@syntax_base), child.base_uri)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement"))
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#subject"), subject)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate"), predicate)
            @graph.add_triple(rsubject, URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#object"), object)
          else
            raise
          end
        end
        
      }
      
    end
    
    private
    def fail_check(el)
      if el.attributes.size != 0 && el.attribute_with_ns("aboutEach", @@syntax_base)
        raise Reddy::AboutEachException
      end
      if el.attributes.size != 0 && el.attribute_with_ns("aboutEachPrefix", @@syntax_base)
        raise Reddy::AboutEachException
      end
      if el.attributes.size != 0 && el.attribute_with_ns("bagID", @@syntax_base)
        raise "Bad BagID" unless el.attribute_with_ns("bagID", @@syntax_base) =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
      end
    end
    
    def parse_subject(el)
      fail_check(el)
      
      if el.attribute_with_ns("about", @@syntax_base)
        #debugger if el.attribute_with_ns("about", @@syntax_base) =~ /artist$/
        return URIRef.new(base_helper(el.attribute_with_ns("about", @@syntax_base), el.base_uri).to_s)
      elsif el.attribute_with_ns("ID", @@syntax_base)
        id = el.attribute_with_ns("ID", @@syntax_base)
        if id_check?(id.value)
          return url_helper("#" + id.value, "", el.base_uri)
        else
          raise
        end
      elsif el.attribute_with_ns("nodeID", @@syntax_base)
        return BNode.new(el.attribute_with_ns("nodeID", @@syntax_base))
      else
        return BNode.new
      end
      subject = nil
      el.attributes.each_attribute do |att|
        uri = url_helper(att.namespaces[["xmlns", att.namespace].join(":")] + att.name).to_s
        value = att.to_s
        if uri == "http://www.w3.org/1999/02/22-rdf-syntax-ns#bagID"
          raise
          if name =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # TODO: do something intelligent with the bagID
          else
            raise
          end
        end
        
        if uri == @@syntax_base + "#resource" || uri == @@syntax_base + "#about" #specified resource
          subject = URIRef.new(base_helper(value, el.base_uri))
        end
        
        if uri.to_s == @@syntax_base + "#nodeID" #BNode with ID
          # we have a BNode with an identifier. First, we need to do syntax checking.
          if value =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
            # now we check to see if the graph has the value
            return forge_bnode_from_string(value)
          end
        end
      end
      
      return subject
    end
    
    def forge_bnode_from_string(value)
      if @graph.has_bnode_identifier?(value)
        # if so, pull it in - no need to recreate objects.
        subject = @graph.get_bnode_by_identifier(value)
      else
        # if not, create a new one.
        subject = BNode.new(value)
      end
      
      return subject
    end
    
    def id_check?(id)
      !(!(id =~ /^[a-zA-Z_]\w*$/))
    end

    protected
    
    def smells_like_xml?(str)
      !(!(str =~ /xmlns/))
    end
    
    def base_helper(uri, base = nil)
      uri = Addressable::URI.parse(uri)
      if uri.relative?
        if !base.nil?
          uri = Addressable::URI.parse(base)
        elsif !@uri.nil?
          uri = Addressable::URI.parse(@uri) + uri
        end
      end
      #debugger if @uri.to_s =~ /bbc\.co\.uk/      
      return uri.to_s
    end
    
    def url_helper(name, ns, base = nil)
      if ns != "" and !ns.nil?
        if ns.to_s.split("")[-1] == "#"
          a = Addressable::URI.parse(ns) + Addressable::URI.parse("#" + name)
        else
          a = Addressable::URI.parse(ns) + Addressable::URI.parse(name)
        end
      else
        a = Addressable::URI.parse(name)
      end
      if a.relative?
        a = base_helper(a.to_s, base)
      end
      
      return URIRef.new(a.to_s)
    end
    
  end
end
