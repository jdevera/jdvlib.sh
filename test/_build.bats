#!/usr/bin/env bats

# executed first in a file
setup_file() {
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    export JDVLIB_COMPILED_PATH=$BATS_FILE_TMPDIR/jdvlib.sh
    pushd "$PROJECT_ROOT" > /dev/null || return 1
    "$PROJECT_ROOT/compile.sh" lib "${JDVLIB_COMPILED_PATH}"
    popd > /dev/null || return 1
}

setup() {
    # shellcheck source=./test_helper/common_setup.bash
    load 'test_helper/common_setup'
    _common_setup
}
teardown() {
    :
}

@test "test_can_run_lib" {
    run bash "$JDVLIB_COMPILED_PATH"
    assert_success
    assert_output_contains 'JDVLib.sh - A library of bash functions for use in other scripts.'
    assert_output_contains 'Version: '
}

@test "test_function_lists_match_when_compiled" {

    # shellcheck source=./../lib/func.sh
    meta::import func
    functions_file="functions.txt"
    functions_compiled_file="functions_compiled.txt"

    meta::for_each_library_module func::list_functions_in_file |
        sort |
        grep -v '^source$' \
        > "$BATS_TEST_TMPDIR/$functions_file"

    func::list_functions_in_file "$JDVLIB_COMPILED_PATH" |
        sort |
        grep -v '^source$' \
        > "$BATS_TEST_TMPDIR/$functions_compiled_file"

    pushd "$BATS_TEST_TMPDIR" > /dev/null || return 1
    run diff -u "$functions_file" "$functions_compiled_file"
    assert_success
    assert_output ""
    popd > /dev/null || return 1
}
