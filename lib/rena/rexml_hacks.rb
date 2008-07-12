require 'rexml/document'

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
end