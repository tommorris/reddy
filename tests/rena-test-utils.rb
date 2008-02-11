require 'rena'
require 'hyperset'

module RenaTestUtils
  def model_to_hyperset(model)
    blank2var_hash = {}
    blank2var = lambda{|x|
      if Rena::Resource === x
        x.uri || (blank2var_hash[x] ||= Hyperset::Variable.new)
      else
        x
      end
    }
  
    var2children = {}
  
    pair2 = lambda{|a,b|
      Hyperset[Hyperset[a], Hyperset[a,b]]
    }
    pair3 = lambda{|a,b,c|
      Hyperset[Hyperset[a], Hyperset[a,b], Hyperset[a,b,c]]
    }
  
    items = []
    model.each_statement{|stmt|
      items << pair3[blank2var[stmt.subject], stmt.predicate, blank2var[stmt.object]]
      if stmt.subject.uri.nil?
        (var2children[blank2var[stmt.subject]] ||= []) << 
          pair2[[true, stmt.predicate], blank2var[stmt.object]]
      end
      if Rena::Resource===stmt.object and stmt.object.uri.nil?
        (var2children[blank2var[stmt.object]] ||= []) <<
          pair2[[false, stmt.predicate], blank2var[stmt.subject]]
      end
    }
  
    eqns = {}
    var2children.each_pair{|var, children|
      eqns[var] = Hyperset[*children]
    }
  
    root = Hyperset::Variable.new
    eqns[root] = Hyperset[*items]
  
    Hyperset.solve(eqns)[root]
  end
end
