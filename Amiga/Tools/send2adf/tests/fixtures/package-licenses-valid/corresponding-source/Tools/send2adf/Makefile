PRESET ?= ci

.PHONY: all configure build test install clean help

all: build

configure:
	cmake --preset $(PRESET)

build: configure
	cmake --build --preset $(PRESET)

test: build
	ctest --preset $(PRESET) --output-on-failure

install:
	cmake --preset production
	cmake --build --preset production
	cmake --install build/production

clean:
	cmake --build --preset $(PRESET) --target clean

help:
	@echo "Usage: make [target] [PRESET=ci|asan|asan-ubsan|production|release]"
	@echo "Targets: all configure build test install clean help"
	@echo "install always configures and builds the production preset"
