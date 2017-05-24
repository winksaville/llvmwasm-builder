# Build llvm, binaryen and wabt for wasm
Based on [yurydelendik wasmllvm](https://gist.github.com/yurydelendik/4eeff8248aeb14ce763ei)

## Building
Options:
  * BUILD_ENGINE=<"Unix Makefiles"|Ninja> the type of build to create (default "Unix Makefiles")
  * BUILD_TYPE=<Release|Debug> the type of build to create (default Release)
  * CPUs=N where N is the number of cpus passed to -j option (default 3)
  * INSTALL_DIR=xxx where xxx is the path to the install directory (default ./bin)
```
make build BUILD_ENGINE=Ninja BUILD_TYPE=Debug CPUS=4 INSTALL_DIR=~/prgs/llvmwasm
```
## Install
You must use the same BUILD_ENGINE and INSTALL_DIR as used when building or none if not specified when building
```
make install BUILD_ENGINE=Ninja INSTALL_DIR=~/prgs/llvmwasm
``
