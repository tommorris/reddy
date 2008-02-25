class Triple
  attr_accessor :subject, :object, :predicate
  def initialize (subject, predicate, object)
    if subject.class == BNode || subject.class == URIRef
      @subject = subject
    elsif subject.class == String
      if subject =~ /\S+\/\/\S+/ # does it smell like a URI?
        @subject = URIRef.new(subject)
      else
        @subject = BNode.new(subject)
      end
    else
      raise "Subject is not of a known class"
    end

    if predicate.class == URIRef
      @predicate = predicate
    elsif predicate.class == BNOde
      raise "BNode is not allowed as a predicate"
    elsif predicate.class == String
      if predicate =~ /\S+\/\/\S+/ # URI smell check again
        @subject = URIRef.new(subject)
      else
        raise "String literals are not acceptable as predicates"
      end
    else
      raise "Predicate should be a uriref"
    end

    if [String, Integer, Fixnum, Float].include? object.class
      @object = Literal.new(object.to_s)
    elsif [URIRef, BNode, Literal, TypedLiteral].include? object.class
      @object = object
    else
      raise "Object expects valid class"
    end
  end

  def to_ntriples
    @subject.to_ntriples + " " + @predicate.to_ntriples + " " + @object.to_ntriples + " ."
  end  
end