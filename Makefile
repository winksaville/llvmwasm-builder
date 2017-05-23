ROOT_DIR=$(shell pwd)
LLVM_WORKDIR=$(ROOT_DIR)/src/llvm
LLVM_BUILDDIR=$(ROOT_DIR)/build/llvm
BINARYEN_WORKDIR=$(ROOT_DIR)/src/binaryen
BINARYEN_BUILDDIR=$(ROOT_DIR)/build/binaryen
INSTALLDIR=$(ROOT_DIR)/bin
CPUs=3

build: build-llvm build-binaryen

clean: clean-llvm clean-binaryen
	rm -rf $(INSTALLDIR)

install: install-llvm install-binaryen

$(LLVM_WORKDIR)/.svn:
	rm -rf $(LLVM_WORKDIR)
	mkdir -p $(LLVM_WORKDIR)
	svn co http://llvm.org/svn/llvm-project/llvm/trunk $(LLVM_WORKDIR)
	svn co http://llvm.org/svn/llvm-project/cfe/trunk $(LLVM_WORKDIR)/tools/clang
	svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk $(LLVM_WORKDIR)/projects/compiler-rt

$(LLVM_BUILDDIR)/Makefile: $(LLVM_WORKDIR)/.svn
	mkdir -p $(LLVM_BUILDDIR)
	cd $(LLVM_BUILDDIR); cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$(INSTALLDIR) -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DLLVM_TARGETS_TO_BUILD= -DCMAKE_BUILD_TYPE=Release $(LLVM_WORKDIR)

build-llvm: $(LLVM_BUILDDIR)/Makefile
	$(MAKE) -C $(LLVM_BUILDDIR) -j $(CPUs) clang llc llvm-lib

clean-llvm:
	rm -rf $(LLVM_WORKDIR)
	rm -rf $(LLVM_BUILDDIR)

install-llvm:
	mkdir -p $(INSTALLDIR)
	$(MAKE) -C $(LLVM_BUILDDIR) install-clang install-llc install-llvm-lib

$(BINARYEN_WORKDIR)/.git:
	rm -rf $(BINARYEN_WORKDIR)
	mkdir -p $(BINARYEN_WORKDIR)
	git clone https://github.com/WebAssembly/binaryen $(BINARYEN_WORKDIR)

$(BINARYEN_BUILDDIR)/Makefile: $(BINARYEN_WORKDIR)/.git
	mkdir -p $(BINARYEN_BUILDDIR)
	cd $(BINARYEN_BUILDDIR); cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$(INSTALLDIR) -DCMAKE_BUILD_TYPE=Release $(BINARYEN_WORKDIR)

build-binaryen: $(BINARYEN_BUILDDIR)/Makefile
	$(MAKE) -C $(BINARYEN_BUILDDIR) -j $(CPUs) wasm-as wasm-dis s2wasm

clean-binaryen:
	rm -rf $(BINARYEN_WORKDIR)
	rm -rf $(BINARYEN_BUILDDIR)

install-binaryen:
	mkdir -p $(INSTALLDIR)
	cp $(addprefix $(BINARYEN_BUILDDIR)/bin/, wasm-as wasm-dis s2wasm) $(INSTALLDIR) 

.PHONY: build clean install build-llvm clean-llvm install-llvm build-binaryen clean-binaryen install-binaryen
