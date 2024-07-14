#!/usr/bin/env bats

# This is executed before each test
setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import env
}

teardown() {
    _run_teardown_functions
}


@test "test_ensure_is_set" {
    local variable=1
    : $variable
    run env::ensure_is_set variable
    assert_success
}

@test "test_ensure_is_set_reassured" {
    local var=1
    : $var
    reassure=true run_stripped env::ensure_is_set var
    assert_success
    assert_output "✔ Variable is set: var"
}

@test "test_ensure_is_set_fail" {
    run_stripped env::ensure_is_set unlikely_to_be_set_variable
    assert_failure
    assert_output "✗ Variable not set: unlikely_to_be_set_variable"
}

@test "test_dotenv_load" {
    cd "$BATS_TEST_TMPDIR"
    local env_file=$BATS_TEST_TMPDIR/.env
    echo "MY_TEST_VAR=yeah" > "$env_file"

    refute_set MY_TEST_VAR
    run_light env::dotenv_load

    assert_success
    assert_set MY_TEST_VAR
    assert_equal "yeah" "$MY_TEST_VAR"
}

@test "test_dotenv_load_custom_file" {
    cd "$BATS_TEST_TMPDIR"
    local env_file=$BATS_TEST_TMPDIR/alt.env
    echo "MY_TEST_VAR=ohyeah" > "$env_file"

    refute_set MY_TEST_VAR

    run_light env::dotenv_load -f "$env_file"

    assert_success
    assert_set MY_TEST_VAR
    assert_equal "ohyeah" "$MY_TEST_VAR"

}

@test "test_dotenv_load_non_existent_file_succeeds" {
    run_light env::dotenv_load -f non_existent_file
    assert_success
}

@test "test_dotenv_load_many_vars" {
    cd "$BATS_TEST_TMPDIR"
    local env_file=$BATS_TEST_TMPDIR/.env
    echo "MY_TEST_VAR=defo" > "$env_file"
    echo "MY_TEST_VAR2=sure" >> "$env_file"

    refute_set MY_TEST_VAR
    refute_set MY_TEST_VAR2

    run_light env::dotenv_load

    assert_success
    assert_set MY_TEST_VAR
    assert_equal "defo" "$MY_TEST_VAR"
    assert_set MY_TEST_VAR2
    assert_equal "sure" "$MY_TEST_VAR2"
}

do_test_dotenv_delete() {
    local env_file_name=$1
    local effective_file_name=.env
    local file_options=()
    if [[ -n $env_file_name ]]; then
        effective_file_name=$env_file_name
        file_options=(-f "$env_file_name")
    fi

    cd "$BATS_TEST_TMPDIR" || return 1
    echo "MY_TEST_VAR=defo" > "$effective_file_name"
    echo "MY_TEST_VAR2=sure" >> "$effective_file_name"

    refute_set MY_TEST_VAR
    refute_set MY_TEST_VAR2

    run env::dotenv_delete "${file_options[@]}" MY_TEST_VAR
    assert_success

    run_light env::dotenv_load "${file_options[@]}"

    assert_success
    refute_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
}

@test "test_dotenv_delete" {
    do_test_dotenv_delete
}

@test "test_dotenv_delete_custom_file" {
    do_test_dotenv_delete alt.env
}


@test "test_dotenv_delete_multiple_vars" {
    cd "$BATS_TEST_TMPDIR"
    echo "MY_TEST_VAR=grumpy" > .env
    echo "MY_TEST_VAR2=happy" >> .env
    echo "MY_TEST_VAR3=neutral" >> .env

    run env::dotenv_delete MY_TEST_VAR MY_TEST_VAR3
    assert_success

    run_light env::dotenv_load

    assert_success
    refute_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
    refute_set MY_TEST_VAR3
}

@test "test_dotenv_delete_non_existent_var_succeeds" {
    cd "$BATS_TEST_TMPDIR"
    echo "MY_TEST_VAR=grumpy" > .env
    echo "MY_TEST_VAR2=happy" >> .env

    run env::dotenv_delete MY_TEST_VAR3
    assert_success

    run_light env::dotenv_load

    assert_success
    assert_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
    refute_set MY_TEST_VAR3
}

@test "test_dotenv_delete_non_existent_file_succeeds" {
    run env::dotenv_delete -f non_existent_file MY_TEST_VAR
    assert_success
}

@test "test_dotenv_save" {
    cd "$BATS_TEST_TMPDIR"
    echo "" > .env

    local MY_TEST_VAR=fantastic
    local MY_TEST_VAR2=amazing

    run env::dotenv_save MY_TEST_VAR MY_TEST_VAR2
    assert_success

    run_light env::dotenv_load

    assert_success
    assert_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
    assert_equal "fantastic" "$MY_TEST_VAR"
    assert_equal "amazing" "$MY_TEST_VAR2"
}

@test "test_dotenv_save_custom_file" {
    cd "$BATS_TEST_TMPDIR"
    local env_file=alt.env
    echo "" > "$env_file"

    local MY_TEST_VAR=outstanding
    local MY_TEST_VAR2=excellent

    run env::dotenv_save -f "$env_file" MY_TEST_VAR MY_TEST_VAR2
    assert_success

    run_light env::dotenv_load -f "$env_file"

    assert_success
    assert_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
    assert_equal "outstanding" "$MY_TEST_VAR"
    assert_equal "excellent" "$MY_TEST_VAR2"
}

@test "test_dotenv_save_existing_entries" {
    cd "$BATS_TEST_TMPDIR"
    echo "MY_TEST_VAR=defo" > .env
    echo "MY_TEST_VAR2=sure" >> .env
    echo "MY_TEST_VAR3=absolutely" >> .env

    local MY_TEST_VAR=grumpy
    local MY_TEST_VAR2=happy

    run env::dotenv_save MY_TEST_VAR MY_TEST_VAR2
    assert_success

    run_light env::dotenv_load

    assert_success
    assert_set MY_TEST_VAR
    assert_set MY_TEST_VAR2
    assert_set MY_TEST_VAR3
    assert_equal "grumpy" "$MY_TEST_VAR"
    assert_equal "happy" "$MY_TEST_VAR2"
    # shellcheck disable=SC2153 # MY_TEST_VAR3 is set in the .env file
    assert_equal "absolutely" "$MY_TEST_VAR3"
}
