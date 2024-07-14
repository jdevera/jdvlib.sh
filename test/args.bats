#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    # shellcheck source=../lib/args.sh
    meta::import args
}

teardown() {
    # executed after each test
    :
}

help_function() {
    echo "helping text"
}

help_script_simulator() {
    args::check_help_arg help_function "$@"
    echo "remainder"
}

assert_help() {
    run help_script_simulator help_function "$@"

    assert_success
    assert_output "helping text"
    refute_output "remainder" # Stopped the script after showing help
}

refute_help() {
    run help_script_simulator help_function "$@"
    assert_success
    refute_output "helping text"
    assert_output "remainder" # The rest of the script should run
}

@test "test_args_check_help_arg" {
    assert_help -h
}

@test "test_args_check_help_arg_long" {
    assert_help --help
}

@test "test_args_check_help_many_args_short" {
    assert_help -v --verbose --help -i
}

@test "test_args_check_help_many_args_long" {
    assert_help --verbose -v --help --input
}

@test "test_args_check_help_arg_no_help" {
    refute_help -v
}

@test "test_args_check_help_arg_no_help_long" {
    refute_help --verbose
}

usage_function() {
    echo "usage text"
}

num_args_simulator() {
    local expected=$1
    shift
    args::ensure_num_args $expected usage_function "$@"
    echo "remainder"
}

@test "test_args_ensure_num_args" {
    run num_args_simulator 3 a b c
    assert_success
    refute_output "usage text"
    assert_output "remainder"
}

@test "test_args_ensure_num_args_too_few" {
    run num_args_simulator 3 a b
    assert_failure
    assert_output "usage text"
    refute_output "remainder"
}

@test "test_args_ensure_num_args_too_many" {
    run num_args_simulator 3 a b c d
    assert_failure
    assert_output "usage text"
    refute_output "remainder"
}

num_args_between_simulator() {
    local min=$1
    local max=$2
    shift 2

    args::ensure_num_args_between $min $max usage_function "$@"
    echo "remainder"
}

@test "test_ensure_num_args_between_ok" {
    run num_args_between_simulator 2 4 a b
    assert_success
    assert_output "remainder"
    refute_output "usage text"
}

@test "test_ensure_num_args_between_too_few" {
    run num_args_between_simulator 2 4 a
    assert_failure
    assert_output "usage text"
    refute_output "remainder"
}

@test "test_ensure_num_args_between_too_many" {
    run num_args_between_simulator 2 4 a b c d e
    assert_failure
    assert_output "usage text"
    refute_output "remainder"
}

@test "test_ensure_num_args_between_no_max" {
    run num_args_between_simulator 2 -1 a b c d e
    assert_success
    assert_output "remainder"
    refute_output "usage text"
}

@test "test_ensure_num_args_between_no_max_too_few" {
    run num_args_between_simulator 2 -1 a
    assert_failure
    assert_output "usage text"
    refute_output "remainder"
}

@test "test_ensure_num_args_between_no_min" {
    run num_args_between_simulator 0 4
    assert_success
    assert_output "remainder"
    refute_output "usage text"
}

flag_value_simulator() {
    args::flag_value --expected $1
}

@test "test_args_flag_value_true" {
    run flag_value_simulator --expected -v something
    assert_success
    assert_output "true"
}

@test "test_args_flag_value_false" {
    run flag_value_simulator -v --expected something_else
    assert_success
    assert_output "false"
}

do_test_get_flag_value() {
    local expected_found_flag=$1
    local expected_other_args=$2
    shift 2
    local __test_flag_value
    local -a __test_other_args
    # Run light because run will not let me set vars in the current shell
    run_light args::get_flag_value --flag __test_flag_value __test_other_args "$@"
    assert_success

    assert [ "$__test_flag_value" == "$expected_found_flag" ]
    assert [ "${__test_other_args[*]}" == "$expected_other_args" ]
}

@test "test_get_flag_value_first" {
    do_test_get_flag_value true "a b" --flag a b
}

@test "test_get_flag_value_middle" {
    do_test_get_flag_value true "a b c" a --flag b c
}

@test "test_get_flag_value_last" {
    do_test_get_flag_value true "a b" a b --flag
}

@test "test_get_flag_value_not_found" {
    do_test_get_flag_value false "a b c" a b c
}

@test "test_get_flag_value_no_args" {
    do_test_get_flag_value false ""
}

@test "test_get_flag_value_only_flag" {
    do_test_get_flag_value true "" --flag
}
