class Foo
  def set(a)
    r = a + a
    r
  end
end

class Bar
  def set(a)
    a
  end
end

obj = rand < 0.5 ? Foo.new : Bar.new
obj.set("a string")

obj.set(1) if obj.is_a?(Foo)
obj.set(1.5) if obj.is_a?(Bar)
