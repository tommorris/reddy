class TestClass
  def initialize(bool)
    if bool == true
      print "Bingbong"
    else
      raise "Not true!"
    end
  end
end

describe "Ruby classes" do
  it "should do something sensible when class raises error while instantiating" do
    if f = TestClass.new(false) do
      
    end
  end
end