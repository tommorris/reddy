require 'rexml/document'

# @ignore
# def subdocument_writer(el)
#   el.prefixes.each { |ns|
#     el.add_attribute('xmlns:' + ns, el.namespaces[ns].to_s)
#   }
#   return el.to_s
# end

class REXML::Element
  public
  
  ## 
  # Tells you whether or not an element has a set xml:lang.
  #
  # @author Tom Morris
  def lang?
    if self.lang != nil
      true
    else
      false
    end
  end
  
  ## 
  # Tells you what the set xml:lang is for an element.
  #
  # ==== Returns
  # @return [String] The URI of the xml:lang.
  # 
  # @author Tom Morris
  def lang
    if self.attributes['xml:lang']
      return self.attributes['xml:lang'].to_s
    elsif self.parent != nil
      return self.parent.lang
    else
      return nil
    end
  end

  ## 
  # Tells you whether or not an element has a set xml:base.
  #
  # @author Tom Morris  
  def base?
    if self.base != nil
      true
    else
      false
    end
  end
  
  ## 
  # Tells you what the set xml:lang is for an element.
  #
  # ==== Returns
  # @return [String] The URI of the xml:base.
  # 
  # @author Tom Morris
  def base
    if self.attributes['xml:base']
      return self.attributes['xml:base'].to_s
    elsif self.parent != nil
      return self.parent.base
    else
      return nil
    end
  end
  
  ## 
  # Allows you to write out an XML representation of a particular element and it's children, fixing namespace issues.
  #
  # ==== Returns
  # @return [String] The XML of the element and it's children.
  # 
  # @author Tom Morris
  def write(excl=[])
    # TODO: add optional list argument of excluded namespaces
    self.prefixes.each { |ns|
      self.add_attribute('xmlns:' + ns, self.namespaces[ns].to_s) unless excl.include? self.namespaces[ns]
    }
    self.support_write_recursive(self.namespaces, self)
    return self.to_s
  end
  
  protected
  def support_write_recursive(array, el)
    el.each_element { |e| 
      unless array.has_key?(e.prefix) && array.has_value?(e.namespace)
        if e.prefix != ""
          e.add_attribute('xmlns:' + e.prefix, e.namespace)
        else
          e.add_attribute('xmlns', e.namespace)
        end
      end
      self.support_write_recursive(array, e)
    }
  end
end