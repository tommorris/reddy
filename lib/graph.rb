require 'lib/namespace'
require 'lib/bnode'
require 'lib/uriref'
require 'lib/literal'
require 'lib/triple'
class Graph
  attr_accessor :triples
  
  def initialize
    @triples = []
  end
  
  def size
    @triples.size
  end
  
  def add_triple(s, p, o)
    @triples += [ Triple.new(s, p, o) ]
  end
  
  def << (triple)
#    self.add_triple(s, p, o)
    @triples += [ triple ]
  end
  
#  alias :add, :add_triple
#  alias (=+, add_triple)
end