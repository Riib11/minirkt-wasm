# minirkt-wasm

## Organization

1. The module `parse.rkt` provides a function `parse` which converts source code
   into an AST for minirkt defined as the prefab `Prgm` in the module
   `grammar.rkt`.
2. The module `interpret.rkt` provides a function `interpret` which interprets a
   `Prgm` and yields the result.
3. The module `compile.rkt` provides a function `compile` which compiles a
   `Prgm` to the corresponding wat (webassembly text format) code.

## Building

To generate the `src/main` executable:

```sh
cd src
raco exe main.rkt
```

## Running

You can compile and run a MiniRkt program by the following steps:

1. Write a MiniRkt program in the `demo/examples/` folder e.g.
   `demo/examples/myprgm.rkt`
2. To compile from MiniRkt to wat, run `./src/main` and enter the
   `demo/examples/myprgm.rkt` file to compile when prompted.
3. To translate from wat to wasm, run
   `wat2wasm demo/examples/myprgm.rkt.wat -o demo/examples/myprgm.rkt.wasm`
   (`wat2wasm` is from the [wabt](https://github.com/WebAssembly/wabt)).
4. To start up a host HTTP server, run `http-server` (from
   [npm](https://www.npmjs.com/package/http-server)).
5. To run the compiled wasm binary, open the address
   `http://<address provided by http-server>:8080` in your browser, enter
   `examples/myprgm.rkt.wasm` into the "filename" field, and click "run". The
   program's output appears in the "output" field.
