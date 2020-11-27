class Q::Person
  property name : String
  property age : Int32

  def initialize(@name, @age)
  end
end

p = Q::Person.new("John", 35)
n = p.name
