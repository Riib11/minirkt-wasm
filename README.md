# minirkt-wasm

## Organization

1. The module `parse.rkt` provides a function `parse` which converts source code
   into an AST for minirkt defined as the prefab `Prgm` in the module
   `grammar.rkt`.
2. The module `interpret.rkt` provides a function `interpret` which interprets a
   `Prgm` and yields the result.
3. The module `compile.rkt` provides a function `compile` which compiles a
   `Prgm` to the corresponding wat (webassembly text format) code.
