.PHONY: all build clean check test checkdist docker
# Default target
all: build

# Build target
build: build/jdvlib.sh

# Specify dependencies for build/jdvlib.sh
LIB_FILES := $(wildcard lib/*)
TEMPLATES := $(wildcard templates/*)
# all files under the test directory, at any level
TESTS := $(wildcard test/**/*)

build/jdvlib.sh: $(LIB_FILES) $(TEMPLATES) compile.sh
	@mkdir -p build
	@./compile.sh lib build/jdvlib.sh

# Clean target
clean:
	@echo "Cleaning up..."
	@rm -rfv build

check: $(LIB_FILES) compile.sh test/test_helper/common_setup.bash
	shellcheck compile.sh
	shellcheck test/test_helper/common_setup.bash
	shellcheck test/*.bats
	shellcheck test/scripts/*.sh
	shellcheck templates/*.sh
	shellcheck --check-sourced lib/lib.sh

checkdist: build/jdvlib.sh
	shellcheck build/jdvlib.sh

testlocal: $(LIB_FILES) $(TESTS)
	@./test/bats/bin/bats test

docker: $(LIB_FILES) $(TEMPLATES) Dockerfile
	@docker build -t jdvlib .

test:
	@docker run -it --rm jdvlib

testdev:
	@docker run -it --rm -v $(PWD):/app jdvlib $(MODULE)

readme:
	@./compile.sh readme

testci:
	echo no
