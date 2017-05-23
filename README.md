# Build llvm for wasm
From [yurydelendik wasmllvm](https://gist.github.com/yurydelendik/4eeff8248aeb14ce763ei)

## Building
Options:
  CPUs=N where N is the number of cpus passed to -j option (default 3)
```
make CPUS=4
```
## Install
Options:
  INSTALLDIR=xxx where xxx is the path to the install directory (default ./bin)
```
make install INSTALLDIR=~/prgs/llvmwasm
``
