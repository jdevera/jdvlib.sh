#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import code
    PATH="$BATS_TEST_DIRNAME/scripts:$PATH"
}

teardown() {
    # executed after each test
    :
}


@test "test_args_check_help_arg" {
    run script_dir.sh
    assert_success
    assert_output "$BATS_TEST_DIRNAME/scripts"
}
