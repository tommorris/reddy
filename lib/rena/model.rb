#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

require 'rena/literal'

module Rena

class Resource
  def initialize(model, uri = nil)
    @model = model
    @uri = uri
  end

  attr_reader :model

  # URI Reference of the resource, or nil for blank node.
  attr_reader :uri

  def add_property(prop, object)
    prop = URI.parse(prop) unless prop.is_a?(URI)
    unless object.is_a?(Resource) or object.is_a?(Literal)
      raise ArgumentError.new(object.inspect + " is not Rena::Resource nor Rena::Literal")
    end
    add_property_impl(prop, object)
    self
  end

  def remove_property(prop, object = nil)
    prop = URI.parse(prop) unless prop.is_a?(URI)
    if object.nil?
      each_property{|p,object|
        remove_property_impl(p, object) if p==prop
      }
    else
      unless object.is_a?(Resource) or object.is_a?(Literal)
        raise ArgumentError.new(object.inspect + " is not Rena::Resource nor Rena::Literal")
      end
      remove_property_impl(prop, object)
    end
  end

  private

  def add_property_impl(prop, object)
    raise RuntimeError.new("implement this method")
  end

  def remove_property_impl(prop, object)
    raise RuntimeError.new("implement this method")
  end

  public

  # call-seq:
  #    rc.have_property(prop,obj)  => true or false
  #
  # Returns <code>true</code> if <i>rc</i> has an property <i>prop</i>,
  # <code>false</code> otherwise.
  # 
  def have_property?(prop, obj)
    prop = URI.parse(prop) unless prop.is_a?(URI)
    unless obj.is_a?(Resource) or obj.is_a?(Literal)
      raise ArgumentError.new(obj.inspect + " is not Rena::Resource nor Rena::Literal")
    end

    each_property{|predicate, object|
      return true if predicate == prop and object == obj
    }
    false
  end

  # call-seq:
  #    rc.get_property(prop)  => node or nil
  #
  # Returns Rena::Resource or Rena::Literal if rc has an property <i>prop</i>,
  # <code>nil</code> otherwise.
  # 
  def get_property(prop)
    prop = URI.parse(prop) unless prop.is_a?(URI)

    each_property{|predicate, object|
      return object if predicate == prop
    }
    nil
  end

  def get_property_values(prop)
    prop = URI.parse(prop) unless prop.is_a?(URI)

    result = Set[]
    each_property{|predicate, object|
      result << object if predicate == prop
    }
    result    
  end

  def [](prop)
    STDERR.puts("warning: Rena::Resource#[] is deprecated. Use Rena::Resource#get_property or Rena::Resource#get_property_values instead.")

    prop = URI.parse(prop) unless prop.is_a?(URI)

    result = []
    each_property{|predicate, object|
      result << object if predicate == prop
    }
    result
  end

  def each_property # :yield: predicate, object
    raise RuntimeError.new("implement this method")
  end
end


 class Statement
  attr_reader :subject
  attr_reader :predicate
  attr_reader :object

  def initialize(subject, predicate, object)
    unless subject.is_a?(Rena::Resource)
      raise ArgumentError.new(subject.inspect + " is not Rena::Resource")
    end
    unless predicate.is_a?(URI)
      raise ArgumentError.new(predicate.inspect + " is not URI")
    end
    unless object.is_a?(Rena::Resource) or object.is_a?(Rena::Literal)
      raise ArgumentError.new(object.inspect + " is not Rena::Resource nor Rena::Literal")
    end
    @subject   = subject
    @predicate = predicate
    @object    = object
  end
end # class Statement


class Error < RuntimeError; end
class LoadError < Error; end
class SaveError < Error; end


class Model

  # Load data from +input+.
  #
  # +input+ is a filename String or IO object.
  # +params+ is a hash of parameters.
  #
  def load(input, params = {})
    if input.respond_to? :gets
      reader = setup_reader(input, params)
      reader.read(input, params)
    else
      open(input, 'rb'){|f|
        reader = setup_reader(f, params)
        reader.read(f, params)
      }
    end

    nil
  end

  private

  def setup_reader(io, params)
    content_type = params[:content_type]
    # for open-uri
    if content_type.nil? and io.respond_to? :content_type
      content_type ||= io.content_type
    end

    case content_type
    #when application/n3
    when /\/n-?triples\Z/i
      reader = NTriples::Reader.new
    #when /application\/trix(\+xml)?/i # http://www.kanzaki.com/memo/2004/02/29-1
    #when /application\/turtle/i # http://www.kanzaki.com/memo/2004/03/27-1
    when /\Aapplication\/.+\+xml\Z/i, /\Atext\/xml\Z/i, /\Aapplication\/xml\Z/i
      reader = XML::Reader.new
    else
      raise RuntimeError.new("unsupported content-type: " + content_type.inspect)
    end
    reader.model = self

    reader
  end

  public

  def save(output, params = {})
    if output.respond_to? :puts
      writer = setup_writer(output, params)
      writer.write(output, self, params)
    else
      open(output, 'wb'){|f|
        writer = setup_writer(f, params)
        writer.write(f, self, params)
      }
    end

    nil
  end
  
  public
  def to_ntriples()
    writer = NTriples::Writer.new
    return writer.model2nt(self)
  end
    
  private

  def setup_writer(io, params)
    content_type = params[:content_type]
    # for open-uri
    if content_type.nil? and io.respond_to? :content_type
      content_type ||= io.content_type
    end

    case content_type
    when /\/n-?triples\Z/i
      writer = NTriples::Writer.new
    when /\Aapplication\/rss\+xml\Z/i, /\Atext\/xml\Z/i, /\Aapplication\/xml\Z/i
      writer = XML::Writer.new
      writer.rss = true
    when /\Aapplication\/rdf\+xml\Z/i, /\Atext\/xml\Z/i, /\Aapplication\/xml\Z/i
      writer = XML::Writer.new
    else
      raise RuntimeError.new("unsupported content-type: " + content_type.inspect)
    end

    writer
  end

  public

  def statements
    result = []
    each_statement{|s| result << s }
    result
  end

  private

  def create_resource_impl
    raise RuntimeError.new("implement this method")
  end

  public

  def create_resource(uri = nil, type = nil)
    uri = URI.parse(uri) if uri and not uri.is_a?(URI)
    resource = create_resource_impl(uri)

    if type
      type = URI.parse(type) unless type.is_a?(URI)
      resource.add_property(URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"),
			    create_resource(type))
    end

    resource
  end

  def lookup_resource(uri)
    uri = URI.parse(uri) unless uri.is_a?(URI)
    lookup_resource_impl(uri)
  end

  private

  def lookup_resource_impl(uri)
    raise RuntimeError.new("implement this method")
  end

  public

  def [](uri)
    lookup_resource(uri)
  end

  def each_resource # :yield: resource
    raise RuntimeError.new("implement this method")
  end

  def each_statement(&block) # :yield: statement
    raise RuntimeError.new("implement this method")
  end

  # Merge _model_.
  # optional _map_ is used to identity blank nodes.
  def merge!(model, map = nil)
    if map.nil?
      map = Hash.new
    else
      map = map.dup
    end

    f = lambda{|x|
      if x.is_a?(Literal)
        x
      elsif x.uri
        create_resource(x.uri)
      else
        map[x] ||= create_resource
      end
    }

    model.each_resource{|from|
      subject = f[from]
      from.each_property{|prop,object|
        subject.add_property(prop, f[x])
      }
    }

    nil
  end
end


end #module Rena
