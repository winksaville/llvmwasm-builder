ROOT_DIR=$(shell pwd)
LLVM_WORKDIR=$(ROOT_DIR)/src/llvm
LLVM_BUILDDIR=$(ROOT_DIR)/build/llvm
BINARYEN_WORKDIR=$(ROOT_DIR)/src/binaryen
BINARYEN_BUILDDIR=$(ROOT_DIR)/build/binaryen
WABT_WORKDIR=$(ROOT_DIR)/src/wabt
WABT_BUILDDIR=$(ROOT_DIR)/build/wabt

#BUILD_ENGINE="Unix Makefiles"
BUILD_ENGINE=Ninja
BUILD_TYPE=Debug
CPUS=3
INSTALL_DIR=$(ROOT_DIR)/dist

ifeq ($(BUILD_ENGINE),Ninja)
MAKE=ninja
MAKEFILE=build.ninja
else
MAKE=make
MAKEFILE=Makefile
endif

LLVM_TARGETS=clang llc llvm-lib llvm-link llvm-config llvm-ar llvm-as llvm-dis lli opt bugpoint

build: build-llvm build-binaryen build-wabt

update: update-llvm update-binaryen update-wabt

clean: clean-llvm clean-binaryen clean-wabt
	rm -rf $(INSTALL_DIR)

dist-clean: dist-clean-llvm dist-clean-binaryen dist-clean-wabt
	rm -rf build/ dist/ src/

install: install-llvm install-binaryen install-wabt

$(LLVM_WORKDIR)/.svn:
	rm -rf $(LLVM_WORKDIR)
	mkdir -p $(LLVM_WORKDIR)
	svn co http://llvm.org/svn/llvm-project/llvm/trunk $(LLVM_WORKDIR)
	svn co http://llvm.org/svn/llvm-project/cfe/trunk $(LLVM_WORKDIR)/tools/clang
	svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk $(LLVM_WORKDIR)/projects/compiler-rt

update-llvm:
	mkdir -p $(LLVM_WORKDIR)
	svn update $(LLVM_WORKDIR)
	svn update $(LLVM_WORKDIR)/tools/clang
	svn update $(LLVM_WORKDIR)/projects/compiler-rt

$(LLVM_BUILDDIR)/$(MAKEFILE): $(LLVM_WORKDIR)/.svn
	mkdir -p $(LLVM_BUILDDIR)
	cd $(LLVM_BUILDDIR); cmake -G $(BUILD_ENGINE) -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DLLVM_TARGETS_TO_BUILD= -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(LLVM_WORKDIR)

build-llvm: $(LLVM_BUILDDIR)/$(MAKEFILE)
	$(MAKE) -C $(LLVM_BUILDDIR) -j $(CPUS) $(LLVM_TARGETS)

clean-llvm:
	rm -rf $(LLVM_BUILDDIR)

dist-clean-llvm: clean-llvm
	rm -rf $(LLVM_WORKDIR)

install-llvm:
	mkdir -p $(INSTALL_DIR)
	$(MAKE) -C $(LLVM_BUILDDIR) $(patsubst %,install-%,$(LLVM_TARGETS))

$(BINARYEN_WORKDIR)/.git:
	rm -rf $(BINARYEN_WORKDIR)
	mkdir -p $(BINARYEN_WORKDIR)
	git clone https://github.com/WebAssembly/binaryen $(BINARYEN_WORKDIR)

update-binaryen:
	mkdir -p $(BINARYEN_WORKDIR)
	(cd $(BINARYEN_WORKDIR) && git pull)

$(BINARYEN_BUILDDIR)/$(MAKEFILE): $(BINARYEN_WORKDIR)/.git
	mkdir -p $(BINARYEN_BUILDDIR)
	cd $(BINARYEN_BUILDDIR); cmake -G $(BUILD_ENGINE) -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(BINARYEN_WORKDIR)

build-binaryen: $(BINARYEN_BUILDDIR)/$(MAKEFILE)
	$(MAKE) -C $(BINARYEN_BUILDDIR) -j $(CPUS) wasm-as wasm-dis wasm-opt s2wasm

clean-binaryen:
	rm -rf $(BINARYEN_BUILDDIR)

dist-clean-binaryen: clean-binaryen
	rm -rf $(BINARYEN_WORKDIR)

install-binaryen:
	mkdir -p $(INSTALL_DIR)
	cp $(addprefix $(BINARYEN_BUILDDIR)/bin/, wasm-as wasm-dis wasm-opt s2wasm) $(INSTALL_DIR)/bin

$(WABT_WORKDIR)/.git:
	rm -rf $(WABT_WORKDIR)
	mkdir -p $(WABT_WORKDIR)
	git clone --recursive https://github.com/WebAssembly/wabt $(WABT_WORKDIR)

update-wabt:
	mkdir -p $(WABT_WORKDIR)
	(cd $(WABT_WORKDIR) && git pull && git submodule update --recursive)

$(WABT_BUILDDIR)/$(MAKEFILE): $(WABT_WORKDIR)/.git
	mkdir -p $(WABT_BUILDDIR)
	cd $(WABT_BUILDDIR); cmake -G $(BUILD_ENGINE) -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(WABT_WORKDIR)

build-wabt: $(WABT_BUILDDIR)/$(MAKEFILE)
	$(MAKE) -C $(WABT_BUILDDIR) -j $(CPUS)

clean-wabt:
	rm -rf $(WABT_BUILDDIR)

dist-clean-wabt: clean-wabt
	rm -rf $(WABT_WORKDIR)

install-wabt:
	mkdir -p $(INSTALL_DIR)
	$(MAKE) -C $(WABT_BUILDDIR) install

.PHONY: build clean dist-clean install
.PHONY: build-llvm dist-clean-llvm clean-llvm install-llvm
.PHONY: build-binaryen dist-clean-binaryen clean-binaryen install-binaryen
.PHONY: build-wabt dist-clean-wabt clean-wabt install-wabt
