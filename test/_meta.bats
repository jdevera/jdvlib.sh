#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
    load 'test_helper/common_setup'
    _common_setup
}

teardown() {
    _run_teardown_functions
}

@test "test_lib_is_not_compiled" {
    run meta::lib_is_compiled
    assert_failure
}

@test "test_lib_is_compiled" {
    __JDVLIB_BUILD_DATE='2024-01-01'
    run meta::lib_is_compiled
    assert_success
}

@test "test_library_path" {
    run meta::library_path
    assert_success
    assert_output "$PROJECT_ROOT/lib"
}

@test "test_library_path_when_compiled" {
    __JDVLIB_BUILD_DATE='2024-01-01'
    run meta::library_path
    assert_failure
    assert_output ""
}

@test "test_import_loads_module" {
    # func module shouldn't be loaded yet
    run -127 func::exists meta::import
    assert_failure

    meta::import func

    # Now func::exists should be available
    run func::exists meta::import
    assert_success
}

@test "test_import_skips_when_compiled" {
    __JDVLIB_BUILD_DATE='2024-01-01'
    # Should return silently without sourcing anything
    run meta::import nonexistent_module
    assert_success
}

@test "test_for_each_library_module" {
    local -a modules=()
    collect_module() {
        modules+=("$(basename "$1")")
    }
    meta::for_each_library_module collect_module
    # Should have found some modules
    [[ ${#modules[@]} -gt 0 ]]
    # _meta.sh should be first
    [[ ${modules[0]} == "_meta.sh" ]]
    # Should contain known modules
    local found_ui=false
    local m
    for m in "${modules[@]}"; do
        [[ $m == "ui.sh" ]] && found_ui=true
    done
    [[ $found_ui == true ]]
}
