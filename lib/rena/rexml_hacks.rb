require 'rexml/document'

# def subdocument_writer(el)
#   el.prefixes.each { |ns|
#     el.add_attribute('xmlns:' + ns, el.namespaces[ns].to_s)
#   }
#   return el.to_s
# end

class REXML::Element
  public
  def lang?
    if self.lang != nil
      true
    else
      false
    end
  end
  def lang
    if self.attributes['xml:lang']
      return self.attributes['xml:lang'].to_s
    elsif self.parent != nil
      return self.parent.lang
    else
      return nil
    end
  end
  
  def base?
    if self.base != nil
      true
    else
      false
    end
  end
  
  def base
    if self.attributes['xml:base']
      return self.attributes['xml:base'].to_s
    elsif self.parent != nil
      return self.parent.base
    else
      return nil
    end
  end
  
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