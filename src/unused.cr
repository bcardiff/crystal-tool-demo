# Shows the unused definitions
#
# Usage:
#
# ```
# $ unused <path/to/compile.cr> <path/to/analyze>
# ```
#
# Symbols declared in <path/to/analyze> that are never used when compiling the programs are reported.
#
# Example:
#
# ```
# # file: src/file.cr
# def foo
# end
#
# def bar
# end
#
# foo
# ```
#
# ```
# $ unused src/file.cr src/
# src/file.cr:5:1 ~> top-level bar
# ```

require "compiler/crystal/**"
include Crystal

# NOTE: counting using the global hash does not work because a defs with no args has always a typed def.
#                 untyped_def => typed_defs
# TYPED_DEFS = {} of Def => Set(Def)

class Crystal::Def
  property untyped_def : Def?
end

class Crystal::Call
  def prepare_typed_def_with_args(untyped_def, owner, self_type, arg_types, block_arg_type, named_args_types)
    typed_def, args = previous_def

    # (TYPED_DEFS[untyped_def] ||= Set(Def).new.compare_by_identity) << typed_def
    typed_def.untyped_def = untyped_def

    {typed_def, args}
  end
end

class CollectDefsVisitor < Visitor
  getter all_defs : Set(Def) = Set(Def).new.compare_by_identity

  def process(result : Compiler::Result)
    accept(result.node)
  end

  def visit(node : ASTNode)
    true
  end

  def visit(node : Def)
    @all_defs << node
    false
  end
end

class RemoveUsedDefsVisitor < Visitor
  include Crystal::TypedDefProcessor

  @visited_defs : Set(Def)

  def initialize(@untyped_defs : Set(Def))
    # these hold the typed defs so they are visited only once
    @visited_defs = Set(Def).new.compare_by_identity
  end

  def process(result : Compiler::Result)
    accept(result.node)
  end

  def visit(node : ASTNode)
    true
  end

  def visit(node : Call)
    if (obj = node.obj) && obj.is_a?(ProcLiteral) && node.name == "call"
      @untyped_defs.delete(obj.def)
      obj.def.body.accept(self)
    end

    node.target_defs.try do |defs|
      defs.each do |typed_def|
        typed_def.accept(self)
      end
    end

    true
  end

  def visit(node : Def)
    return false if @visited_defs.includes?(node)

    @visited_defs << node
    if untyped_def = node.untyped_def
      @untyped_defs.delete(untyped_def)
      true
    else
      false
    end
  end
end

# main file
filename = ARGV[0]

# consider symbols defined within this directory only
filter_locations = ARGV[1]?.try { |v| File.expand_path(v) }

# a comma separated list of path to focus
forced_type_names = ARGV[2]?.try { |x| Regex.new(x) }

# compile without codegen
compiler = Compiler.new
compiler.no_codegen = true
source = Compiler::Source.new(filename, File.read(filename))
result = compiler.compile(source, "not-used")

visitor = CollectDefsVisitor.new
visitor.process(result)

RemoveUsedDefsVisitor.new(visitor.all_defs).process(result)

visitor.all_defs.each do |a_def|
  report_location = a_def.location.try(&.expanded_location).try(&.to_s) || "(???)" rescue "(???)"
  report_name = a_def.short_reference rescue "(???)"

  next if report_location != "(???)" &&
          # is not in user interested location
          !File.expand_path(report_location).to_s.starts_with?(filter_locations.to_s) &&
          # if type name filter is activated, if it does not match
          (!forced_type_names || !forced_type_names.matches?(report_name))

  # typed_defs_count = TYPED_DEFS[a_def]?.try(&.size) || 0
  # next if typed_defs_count > 0

  puts "#{report_location} ~> #{report_name}"
end
