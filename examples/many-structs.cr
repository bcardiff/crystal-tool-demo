require "./many-structs.reorder"

annotation GenerateReorderHint
end

@[GenerateReorderHint]
record Foo, a : Int8, b : Int16, c : Int32, d : Int64

@[GenerateReorderHint]
class FooClass
  @a : Int8 = 0
  @b : Int16 = 0
  @c : Int32 = 0
  @d : Int64 = 0
end

record Bar, a : Int8, b : Int16, c : Int32, d : Int64

module Qux
  @[GenerateReorderHint]
  record Baz, a : String, b : Int16, c : Int32
end

module Asd
  class Zxc # (T) # TODO Handle generic arguments when going from base class to class definition
  end

  class A128
    @a = 0i64
    @b = 0i64
  end

  class Qwe(T)
    @[GenerateReorderHint]
    class Ert(S) < Zxc # (S)
      @b : String = ""
      @c : Int32 = 0
      @d : Int64 = 0
      @e : A128 = A128.new

      def initialize(@a : S)
      end
    end
  end
end

# TODO Ivars with Unions
# TODO Base class with namespace
