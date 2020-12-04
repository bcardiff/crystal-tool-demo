# Tool Demo for Crystal

This repo contains sample code to demonstrate existing crystal tools.

It also shows how to create your own tools that relay con crystal compile.

The tool in `tool-ivars-count` shows types in a program ordered by the amount of instance variables.

## How to use it

1. Install Crystal
2. Install llvm
3. Ensure llvm-config is in the path or set `LLVM_CONFIG` environment variable
4. Build the tool `$ make bin/ivars-count`
5. Use the tool in your codebase `$ bin/ivars-count examples/namespaced-class-declaration.cr`

The `ivars-count` program takes a filename input (`examples/namespaced-class-declaration.cr` in the above example) and **compiles** it. This means the tool _is a Crystal compiler_.

In case you want to use crystal HEAD or working copy you can

```
$ make bin/ivars-count CRYSTAL=path/to/crystal
```

## Available tools

* **ivars-count**: types in a program ordered by the amount of instance variables
* **top-level**: top level symbol names and it's kind
* **unused**: report unused symbols
* **reorder-ivar**: reorder ivars from bigger to smaller size in specific types
