# env CRYSTAL_CONFIG_PATH=$($crystal env CRYSTAL_PATH) $crystal tool-top-level-types.cr -- ../master/spec/std_spec.cr ../master/spec/

require "compiler/crystal/**"
include Crystal

# get source file
filename = ARGV[0]
filename = File.expand_path(filename)

ignore_locations = ARGV[1].try { |v| File.expand_path(v) }

# compile without codegen
compiler = Compiler.new
compiler.no_codegen = true
source = Compiler::Source.new(filename, File.read(filename))
result = compiler.compile(source, "not-used")

# declare tool results
record TopLevelResult, name : String, kind : String, locations : Array(Location)?
output = [] of TopLevelResult

exception_base = result.program.exception

# start with top level types and modules
result.program.types.values.each do |type|
  locations = type.locations
  next if locations && ignore_locations && locations.all?(&.original_location.to_s.starts_with?(ignore_locations))

  kind = case
         when type.covariant?(exception_base)
           "exception"
         else
           type.type_desc
         end

  output << TopLevelResult.new(name: type.name, kind: kind, locations: locations)
end

if (program_defs = result.program.defs)
  program_defs.each do |name, defs|
    next unless defs.any? { |_def|
                  !((location = _def.def.location) && ignore_locations &&
                  location.original_location.to_s.starts_with?(ignore_locations))
                }
    output << TopLevelResult.new(name: name, kind: "method", locations: nil)
  end
end

if (program_macros = result.program.macros)
  program_macros.each do |name, macros|
    next unless macros.any? { |_macro|
                  !((location = _macro.location) && ignore_locations &&
                  location.original_location.to_s.starts_with?(ignore_locations))
                }
    output << TopLevelResult.new(name: name, kind: "macro", locations: nil)
  end
end

# sort the output
output.sort_by! &.name

# print the output
output.each do |e|
  puts "#{e.kind},#{e.name}"

  # if ls = e.locations
  #   ls.each do |l|
  #     l = l.original_location
  #     next if l.to_s.starts_with?(ignore_locations)
  #     puts "  #{l}"
  #   end
  # end
end
