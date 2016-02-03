class Foo
  def hi
    "I'm a foo"
  end
end

class Bar
  def hi
    "I'm a bar"
  end
end

obj = rand < 0.5 ? Foo.new : Bar.new
obj.hi
