require 'lib/bnode'
class Triple
  attr_accessor :subject, :object, :predicate
  def to_ntriples
    @subject.to_ntriples + " " + @predicate.to_ntriples + " " + @object.to_ntriples + " ."
  end
end