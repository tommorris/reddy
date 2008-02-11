#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

require 'rena/model'
require 'set'

module Rena


class MemModel < Model
  def initialize
    @uri_to_resources = Hash.new
    @blank_nodes = Array.new
  end

  def each_resource(&block)
    @uri_to_resources.each_value(&block)
    @blank_nodes.each(&block)
  end

  private

  def create_resource_impl(uri)
    if uri.nil?
      res = Resource.new(self)
      @blank_nodes << res
      res
    else
      uri = URI.parse(uri) unless uri.is_a?(URI)
      @uri_to_resources[uri] ||= Resource.new(self, uri)
    end
  end

  def lookup_resource_impl(uri)
    @uri_to_resources[uri]
  end

  public

  def each_statement(&block)
    each_resource{|subject|
      subject.each_property{|prop, object|
	yield Statement.new(subject, prop, object)
      }
    }
  end

  ##

  class Resource < Rena::Resource
    def initialize(model, uri = nil)
      super
      @properties = Hash.new
    end

    private

    def add_property_impl(prop, object)
      (@properties[prop] ||= Set[]) << object
    end

    def remove_property_impl(prop, object)
      if s = @properties[prop]
        s.delete(object)
      end
    end

    public

    def each_property
      @properties.each{|prop, objects|
	objects.each{|object|
	  yield(prop, object)
	}
      }
    end
  end # class Resource

end # class MemModel


end # module Rena
