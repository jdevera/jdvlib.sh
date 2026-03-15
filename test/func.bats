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

@test "test_call_first_matching_finds_second" {
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    _greet() { echo "hello $*"; }
    checker() { func::exists "$1"; }
    run func::call_first_matching checker _nonexistent _greet -- world
    assert_success
    assert_output "hello world"
}

@test "test_call_first_matching_none_found" {
    run func::call_first_matching func::exists _no _nope _nada
    assert_failure
}

@test "test_call_first_matching_no_args" {
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    _say_hi() { echo "hi"; }
    run func::call_first_matching func::exists _say_hi
    assert_success
    assert_output "hi"
}

@test "test_call_first_of" {
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    _second() { echo "got $*"; }
    run func::call_first_of _first _second -- arg1
    assert_success
    assert_output "got arg1"
}
