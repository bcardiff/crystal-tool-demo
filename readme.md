# Tool Demo for Crystal

This repo contains sample code to demonstrate existing crystal tools.

It also shows how to create your own tools that relay con crystal compile.

The tool in `tool-ivars-count` shows all the types used in a program ordered by the amount of instance variables.

## How to use it

1. Install crystal with llvm
2. Execute

```
$ export crystal=crystal # or /path/to/crystal
$ env CRYSTAL_CONFIG_PATH=$($crystal env CRYSTAL_PATH) $crystal tool-ivars-count.cr -- sample.cr
```

The program `tool-vars-count.cr` takes a filename input (`sample.cr` in the above example) and **compiles** it. This means the tool is a crystal compiler. There are some details of how crystal compiler is shipped that force us to point the source of the crystal std. This is done by setting `CRYSTAL_CONFIG_PATH`.

In case you want to use crystal HEAD or working copy you can

```
$ env CRYSTAL_CONFIG_PATH=$(path/to/crystal env CRYSTAL_PATH) path/to/crystal tool-ivars-count.cr -- sample.cr
```

In order to build the tool once and run it multiple times:

1. `$ env CRYSTAL_CONFIG_PATH=$(crystal env CRYSTAL_PATH) crystal tool-ivars-count.cr`
2. `$ ./tool-ivars-count sample.cr`
3. `$ ./tool-ivars-count other_sample.cr`
