.PHONY: all build clean check test checkdist
# Default target
all: build

# Build target
build: build/jdvlib.sh

# Specify dependencies for build/jdvlib.sh
LIB_FILES := $(wildcard lib/*)
TEMPLATES := $(wildcard templates/*)

build/jdvlib.sh: $(LIB_FILES) $(TEMPLATES) compile.sh
	@mkdir -p build
	@./compile.sh lib build/jdvlib.sh

# Clean target
clean:
	@echo "Cleaning up..."
	@rm -rfv build

check: $(LIB_FILES) compile.sh
	@shellcheck compile.sh
	@shellcheck --source-path=lib \
	            --check-sourced \
	            --external-sources \
	            lib/lib.sh

checkdist: build/jdvlib.sh
	shellcheck build/jdvlib.sh

test: $(LIB_FILES)
	@./test/bats/bin/bats test
