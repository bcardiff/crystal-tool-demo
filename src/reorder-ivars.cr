# This tools will generate a complimentary crystal source file that will hint
# the compiler to reorder instance variables in decreasing size order.
#
# Usage:
#
# Declare in your program
#
# ```
# annotation GenerateReorderHint
# end
# ```
#
# And use it in the types you want to reorder: class, struct, records.
#
# ```
# @[GenerateReorderHint]
# class MyBigType
#   # ...
# end
# ```
#
# To view the hint source you can use
#
# ```
# $ reorder-ivars <path/to/compile.cr>
# ```
#
# Or emit it to a complimentary source location, and optionally format it.
#
# ```
# $ reorder-ivars <path/to/compile.cr> > ./src/reorder-hint.cr
# $ crystal tool format ./src/reorder-hint.cr
# ```
#
# Change your program to require ./src/reorder-hint.cr as soon as possible.
#
# ```
# require "./reorder-hint"
# ```
#
# Check examples/many-structs.cr and examples/many-structs.reorder.cr
#
# You can check the ivar order using the hierarchy tool:
#
# ```
# $ crystal tool hierarchy examples/many-structs.cr -e Ert
# $ crystal tool hierarchy examples/many-structs.cr -Dtool_reorder -e Ert
# ```
#
# The tool will ignore the hint source thanks to the tool_reorder flag.

require "compiler/crystal/**"
include Crystal

class TypesProcessor
  @declared : Set(Type)

  def initialize(@output : IO, @hint_annotation : AnnotationType, @program : Program)
    emit_reorder_prelude
    @declared = Set(Type).new.compare_by_identity
  end

  def process(program)
    # start with top level types and modules
    process_types(program.types.values)
  end

  def process_types(types)
    types.each do |type|
      if type.is_a?(Annotatable) && type.annotation(@hint_annotation)
        emit_type(type)
      end

      type.types?.try { |inner_types| process_types(inner_types.values) }
    end
  end

  def start_type_declaration(type)
    @output << "abstract " if type.abstract?
    @output << (
      case
      when type.struct?; "struct"
      when type.module?; "module"
      else               "class"
      end
    )

    @output << " " << type

    if superclass = non_implicit_superclass(type)
      @output << " < " << superclass
    end

    @output << "\n"
  end

  def non_implicit_superclass(type)
    if superclass = type.superclass
      return nil if superclass == @program.types["Struct"]
      return nil if superclass == @program.types["Reference"]
      return superclass
    end
  end

  def emit_type(type)
  end

  def emit_type(type : ModuleType | GenericInstanceType)
    return if type.is_a?(Program)
    return if @declared.includes?(type)
    @declared << type

    if type.is_a?(NamedType)
      emit_type(type.namespace)
    end

    if superclass = non_implicit_superclass(type)
      emit_type(superclass)
    end

    if type.is_a?(Annotatable) && type.annotation(@hint_annotation)
      # check all instance variable types are defined before declaring this
      type.instance_vars.values
        .each do |ivar|
          case t = ivar.type?
          when Nil
          when TypeParameter
          else
            emit_type(t)
          end
        end

      start_type_declaration(type)
      emit_order_ivars(type)
    else
      start_type_declaration(type)
    end

    @output << "end\n\n"
  end

  def emit_order_ivars(type)
    type.instance_vars.values
      .sort_by { |ivar| size_of(ivar.type?) }
      .reverse_each do |ivar|
        @output << "  " << ivar << " : " << ivar.type? << "\n"
      end
  end

  def size_of(type)
    case type
    when Nil
      0
    when TypeParameter
      # generic type parameters can't be determined for all instances.
      0
    else
      @program.size_of(type)
    end
  end

  def emit_reorder_prelude
    @output.puts "{% skip_file if flag?(:tool_reorder) %}"
    @output.puts
  end
end

# main file
filename = ARGV[0]

# compile without codegen
compiler = Compiler.new
compiler.no_codegen = true
compiler.flags << "tool_reorder"
source = Compiler::Source.new(filename, File.read(filename))
result = compiler.compile(source, "not-used")

hint_annotation = result.program.types["GenerateReorderHint"].as(AnnotationType)

TypesProcessor.new(STDOUT, hint_annotation, result.program).process(result.program)
