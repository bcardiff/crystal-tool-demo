# $ bin/unused examples/some-unused-defs.cr examples/

def foo
end

def bar
end

def baz(x)
end

module Q
  class W
    def initialize(n)
    end

    def foo
    end

    def bar
    end

    def baz(x)
    end
  end
end

class E
  property r : Int32 = 0
end

class F(X)
  def g
  end

  def h
  end

  def self.i
  end

  def self.j
  end
end

record K, l : Int32, m : String

foo
Q::W.new(0).bar
E.new.r = 42
F(Int32).new.h
F.j
K.new(0, "")

spawn bar

spawn baz(0)

->{
  baz(0)
}.call

BAR = bar

BAR
