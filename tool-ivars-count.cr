require "compiler/crystal/**"
include Crystal

# get source file
filename = ARGV[0]
filename = File.expand_path(filename)

# compile without codegen
compiler = Compiler.new
compiler.no_codegen = true
source = Compiler::Source.new(filename, File.read(filename))
result = compiler.compile(source, "not-used")

# declare tool results
record TypeIVarResult, type, ivars_count
$output = [] of TypeIVarResult

# collect types and ivars count
def process_types(types)
  types.each do |type|
    if type.responds_to?(:instance_vars)
      $output << TypeIVarResult.new(type, type.instance_vars.size)
    end

    if type.responds_to?(:types)
      process_types(type.types.values)
    end
  end
end

# start with top level types and modules
process_types(result.program.types.values)

# sort the output
$output.sort! { |a, b| b.ivars_count <=> a.ivars_count }

# print the output
$output.each do |e|
  puts "#{e.type}, #{e.ivars_count}"
end
