#!/usr/bin/env bats

# executed first in a file
setup_file() {
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    export JDVLIB_COMPILED_PATH=$BATS_FILE_TMPDIR/jdvlib.sh
    pushd "$PROJECT_ROOT" > /dev/null || return 1
    "$BASH" ./compile.sh lib "${JDVLIB_COMPILED_PATH}"
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
    assert_output_contains 'A library of bash functions for use in other scripts.'
    assert_output_contains 'Version: '
}

@test "test_function_lists_match_when_compiled" {

    # shellcheck source=./../lib/func.sh
    meta::import func
    functions_file="$BATS_TEST_TMPDIR/functions.txt"
    functions_compiled_file="$BATS_TEST_TMPDIR/functions_compiled.txt"

    # Run module listing in parallel: one job per module + one for compiled
    local tmpdir="$BATS_TEST_TMPDIR/parts"
    mkdir -p "$tmpdir"

    local file i=0
    while IFS= read -r file; do
        func::list_functions_in_file "$__JDVLIB_PATH/$file" > "$tmpdir/$i" &
        i=$((i + 1))
    done < <(awk '/^source / { print $2 }' "$__JDVLIB_PATH/lib.sh")

    func::list_functions_in_file "$JDVLIB_COMPILED_PATH" |
        sort |
        grep -v '^source$' \
        > "$functions_compiled_file" &

    wait

    sort "$tmpdir"/* | grep -v '^source$' > "$functions_file"

    run diff -u "$functions_file" "$functions_compiled_file"
    assert_success
    assert_output ""
}
