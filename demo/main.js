var filename_input = document.getElementById("filename");
var output_elem = document.getElementById("output");
var error_elem = document.getElementById("error");

function run_onclick() {
  let fn = filename_input.value;
  console.log(fn);
  run_wasm(fn);
}

function run_wasm(fn) {
  error_elem.textContent = "";
  fetch(fn)
    .catch(err => {
      console.error(err);
      error_elem.textContent = err;
    })
    .then(response => response.arrayBuffer())
    .then(bytes => WebAssembly.instantiate(bytes))
    .then(results => {
      instance = results.instance;
      output_elem.textContent = 
        instance.exports.main();
    })
}