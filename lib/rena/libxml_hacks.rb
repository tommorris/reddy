require 'xml'
class LibXML::XML::Node
  def namespaced_to_s
    self.copy(true).to_s
  end
end