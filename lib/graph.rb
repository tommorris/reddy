require 'lib/triple'
class Graph
  attr_accessor :triples
  
  def initialize
    @triples = []
  end
  
  def add_triple(s, p, o)
    @triples + [ Triple.new(s, p, o) ]
  end
  
#  alias (<<, add_triple)
#  alias (=+, add_triple)
end