# Shows the type and their instance variables count in descending order

require "compiler/crystal/**"
include Crystal

record TypeIVarResult, type : Type, ivars_count : Int32

class TypesProcessor
  @result = [] of TypeIVarResult

  # collect types and ivars count
  def process_types(types)
    types.each do |type|
      if type.is_a?(InstanceVarContainer)
        @result << TypeIVarResult.new(type, type.instance_vars.size)
      end

      type.types?.try { |inner_types| process_types(inner_types.values) }
    end
  end

  def process(program)
    # start with top level types and modules
    process_types(program.types.values)

    # sort the output
    @result.sort! { |a, b| b.ivars_count <=> a.ivars_count }

    @result
  end
end

# get source file
filename = ARGV[0]
filename = File.expand_path(filename)

# compile without codegen
compiler = Compiler.new
compiler.no_codegen = true
source = Compiler::Source.new(filename, File.read(filename))
result = compiler.compile(source, "not-used")

# visit program output
TypesProcessor.new
  .process(result.program)
  .each do |e|
    puts "#{e.type}, #{e.ivars_count}"
  end
