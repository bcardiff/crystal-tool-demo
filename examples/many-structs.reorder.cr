{% skip_file if flag?(:tool_reorder) %}

abstract class Object
end

abstract struct Value < Object
end

abstract struct Number < Value
end

abstract struct Int < Number
end

struct Int8 < Int
end

struct Int16 < Int
end

struct Int32 < Int
end

struct Int64 < Int
end

struct Foo
  @d : Int64
  @c : Int32
  @b : Int16
  @a : Int8
end

class FooClass
  @d : Int64
  @c : Int32
  @b : Int16
  @a : Int8
end

module Qux
end

class String
end

struct Qux::Baz
  @a : String
  @c : Int32
  @b : Int16
end

module Asd
end

class Asd::Qwe(T)
end

class Asd::Zxc
end

class Asd::A128
end

class Asd::Qwe::Ert(S) < Asd::Zxc
  @e : Asd::A128
  @d : Int64
  @b : String
  @c : Int32
  @a : S
end
