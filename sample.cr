class Q::Person
  property name
  property age

  def initialize(@name, @age)
  end
end

p = Q::Person.new("John", 35)
n = p.name
