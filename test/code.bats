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


@test "test_script_dir" {
    run script_dir.sh script
    assert_success
    assert_output "$BATS_TEST_DIRNAME/scripts"
}

@test "test_script_dir_sourced" {
    # Test the extra level parameter of code::script_dir
    run script_dir.sh sourced-file 1
    assert_success
    assert_output "$BATS_TEST_DIRNAME/scripts"
}

@test "test_is_sourced" {
    run sourced_checker.sh
    assert_success
    assert_output "ran"

    run source sourced_checker.sh
    assert_success
    assert_output "sourced"
}