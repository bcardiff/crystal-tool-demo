# Tool Demo for Crystal

This repo contains sample code to demonstrate existing crystal tools.

It also shows how to create your own tools that relay con crystal compile.

The tool in `tool-ivars-count` shows all the types used in a program ordered by the amount of instance variables.

## How to use it

1. Install crystal with llvm
2. Execute

```
$ CRYSTAL_CONFIG_PATH=/usr/local/Cellar/crystal-lang/0.14.2/src crystal tool-ivars-count.cr -- sample.cr
```

The program `tool-vars-count.cr` takes a filename input (`sample.cr` in the above example) and **compiles** it. This means to tool is a crystal compiler. There are some details of how crystal compiler is shipped that force us to point the source of the crystal std. The std shipped with the crystal compiler can be used, hence `CRYSTAL_CONFIG_PATH=/usr/local/Cellar/crystal-lang/0.14.2/src` at the beginning of the command.

In order to build the tool once and run it multiple times:

1. `$ CRYSTAL_CONFIG_PATH=/usr/local/Cellar/crystal-lang/0.14.2/src crystal tool-ivars-count.cr`
2. `$ ./tool-ivars-count sample.cr`
