#!/usr/bin/env bats

__TEARDOWN_FUNCTIONS=()

# This is executed before each test
setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import ui
}

teardown() {
    _run_teardown_functions
}

@test "test_ok" {
    run_stripped ui::ok "all good"

    assert_success
    assert_output "✔ all good"
}

@test "test_fail" {
    run_stripped ui::fail "not good"

    assert_success
    assert_output "✗ not good"
}

@test "test_die" {
    run_stripped ui::die "dead"

    assert_failure
    assert_output "✗ dead"
}

@test "test_info" {
    run_stripped ui::info "info"

    assert_success
    assert_output "ℹ info"
}

@test "test_noop" {
    run_stripped ui::noop "noop"

    assert_success
    assert_output "∅ noop"
}

@test "test_deprecate" {
    run_stripped ui::deprecate "old" "new"

    assert_success
    assert_output " The function old is deprecated. Use new instead."
}

@test "test_deprecate_no_replacement" {
    run_stripped ui::deprecate "old"

    assert_success
    assert_output " The function old is deprecated."
}

@test "test_deprecate_with_debug" {
    deprecated_function() {
        ui::deprecate "old" "new"
    }
    SCRIPTS_DIR="$BATS_TEST_DIRNAME/scripts"
    PATH="$SCRIPTS_DIR:$PATH"

    JDVLIB_DEBUG=1 run_stripped deprecated_function.sh

    assert_success

    assert_equal "${lines[0]}" " $SCRIPTS_DIR/deprecated_function.sh:17: The function old_function is deprecated. Use new_function instead."
    assert_equal "${lines[1]}" "still work"
}

@test "test_echo_step" {
    run_stripped ui::echo_step "step"

    assert_success
    assert_output "➜ step"
}

@test "test_echo_step_with_prefix" {

    test_function() {
        prefix=FOO ui::echo_step "step"
    }
    run_stripped test_function

    assert_success
    assert_output "FOO➜ step"
}

@test 'test_ask' {
    source args.sh

    ui::ask "question" answer "default" <<<"YES"
    assert_equal "$?" 0
    assert_equal "$answer" "YES"
}

@test 'test_ask_default' {
    source args.sh
    ui::ask "question" answer "default" <<<""
    assert_equal "$?" 0
    assert_equal "$answer" "default"
}

@test 'test_ask_preloaded_value' {
    source args.sh
    answer="preloaded"
    run ui::ask "question" answer "default"

    assert_success
    assert_equal "$answer" "preloaded"
}

@test 'test_ask_mocked_read' {
    source args.sh

    read() { local -n __mock_var=$4; __mock_var="mocked"; }

    enable_read_builtin() { enable read; }
    disable_read_builtin() { enable -n read; }

    register_teardown enable_read_builtin
    disable_read_builtin
    ui::ask "question" answer "default"
    assert_equal "$?" 0
    assert_equal "$answer" "mocked"
}
