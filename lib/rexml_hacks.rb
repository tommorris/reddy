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
end