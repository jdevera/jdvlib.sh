#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import func
}

teardown() {
    _run_teardown_functions
}

@test "test_func_exists_true" {
    _a_real_function() { :; }
    run func::exists _a_real_function
    assert_success
}

@test "test_func_exists_false" {
    run func::exists _a_function_that_does_not_exist
    assert_failure
}
