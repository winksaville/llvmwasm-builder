# Build llvm, binaryen and wabt for wasm
Based on [yurydelendik wasmllvm](https://gist.github.com/yurydelendik/4eeff8248aeb14ce763e)

## Prerequesites
  * Gcc 6+
  * ninja

## Building
Options:
- BUILD_ENGINE=<Ninja|"Unix Makefiles"> the type of build to create (default Ninja)
- BUILD_TYPE=<Release|Debug> the type of build to create (default Release)
- CPUs=N where N is the number of cpus passed to -j option (default 2)
- INSTALL_DIR=xxx where xxx is the path to the install directory (default ./dist)
```
make build BUILD_ENGINE=Ninja BUILD_TYPE=Debug CPUS=4 INSTALL_DIR=~/prgs/llvmwasm
```
## Install
You must use the same BUILD_ENGINE and INSTALL_DIR as used when building or none if not specified when building
```
make install BUILD_ENGINE=Ninja INSTALL_DIR=~/prgs/llvmwasm
```
## Clean
Clean binaries and install targets
```
make clean
```

## Distributation clean
Clean binaries, install targets and sources
```
make dist-clean
```
