#!/usr/bin/env bash

__TEARDOWN_FUNCTIONS=()

_common_setup() {
    # shellcheck source=./bats-support/load.bash
    load 'test_helper/bats-support/load'
    # shellcheck source=./bats-assert/load.bash
    load 'test_helper/bats-assert/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    # bashsupport disable=BP2001
    export __JDVLIB_PATH PROJECT_ROOT
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    __JDVLIB_PATH="$PROJECT_ROOT/lib"
    # make executables in src/ visible to PATH
    PATH="$__JDVLIB_PATH:$PATH"
    # shellcheck source=./../../lib/_meta.sh
    source "$__JDVLIB_PATH/_meta.sh"
}

strip_ansi() {
    echo "$1" | sed -E 's/\x1B\[[0-9;]*[JKmsu]//g'
}
strip_ansi_from_output() {
    declare -g output lines

    output=$(strip_ansi "$output")

    # replace the lines array with the stripped lines
    for i in "${!lines[@]}"; do
        lines[i]=$(strip_ansi "${lines[$i]}")
    done

}

run_stripped() {
    run "$@"
    strip_ansi_from_output
}

puts() {
    echo "$@" >&3
}

cat3() {
    cat "$@" >&3
}

is_docker_container() {
    [[ -f /.dockerenv ]]
}


skip_unless_docker_container() {
    is_docker_container || skip "This test must be run in a docker container"
}

skip_unless_root() {
    [[ $EUID -eq 0 ]] || skip "This test must be run as root"
}

register_teardown() {
    local function=$1
    declare -ga __TEARDOWN_FUNCTIONS
    __TEARDOWN_FUNCTIONS+=("$function")
}


_run_teardown_functions() {
    # Run and remove all teardown functions
    # first make a local copy of the array to ensure cleanup even if a function fails
    declare -ga __TEARDOWN_FUNCTIONS
    local functions=("${__TEARDOWN_FUNCTIONS[@]}")
    __TEARDOWN_FUNCTIONS=()
    local function
    # run the functions in reverse order:
    for ((i=${#functions[@]}-1; i>=0; i--)); do
        function=${functions[$i]}
        log_teardown "$function"
        $function
    done
}

assert_set() {
    local -n var=$1
    if [[ -z $var ]]; then
        batslib_print_kv_single 8 \
        'variable' "\$$1" \
        | batslib_decorate 'Variable not set' \
        | fail
    fi
}

refute_set() {
    local -n var=$1
    if [[ -n $var ]]; then
        batslib_print_kv_single_or_multi 8 \
        'variable' "\$$1" \
        'content' "$var" \
        | batslib_decorate 'Variable is set' \
        | fail
    fi
}

assert_output_contains() {
    local expected=$1
    if [[ $output != *"$expected"* ]]; then
        batslib_print_kv_single_or_multi 8 \
        'expected' "$expected" \
        'output' "$output" \
        | batslib_decorate 'Output does not contain expected string' \
        | fail
    fi
}

run_light() {
    # Using redirections here to avoid the need for a subshell
    # Using a subshell would make it impossible to set variables in the parent shell
    "$@" &>"$BATS_TEST_TMPDIR/run_light.out"
    status=$?
    output=$(<"$BATS_TEST_TMPDIR/run_light.out")
    return $status
}

test_ensure_function() {
    local ensure_function=$1
    # if ensure is not in the name, issue a warning
    if [[ $ensure_function != *ensure* ]]; then
        puts "# WARNING: test_ensure_function is intended to be used with ensure functions"
    fi
    shift
    local expected_failure=
    local expected_reassurance=
    local run_success=false
    local run_failure=false
    local -a success_args=()
    local -a failure_args=()
    local mode=
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --success)
                mode=success
                expected_reassurance=$2
                run_success=true
                shift
                ;;
            --failure)
                mode=failure
                expected_failure=$2
                run_failure=true
                shift
                ;;
            *)
                if [[ $mode == success ]]; then
                    success_args+=("$1")
                elif [[ $mode == failure ]]; then
                    failure_args+=("$1")
                else
                    ui::die "unknown argument $1"
                fi
                ;;
        esac
        shift
    done

    # First the success case (without reassurance)
    if $run_success; then
        puts "# Running success case for $ensure_function with args: ${success_args[*]}"
        run_stripped "$ensure_function" "${success_args[@]}"
        assert_success
        assert_output ""

        # Then the success case (with reassurance)
        if [[ -n $expected_reassurance ]]; then
            puts "# Running success case for $ensure_function with reassurance with args: ${success_args[*]}"
            reassure=true run_stripped "$ensure_function" "${success_args[@]}"
            assert_success
            assert_output "✔ $expected_reassurance"
        fi
    fi

    # Finally, the failure case
    if $run_failure; then
        puts "# Running failure case for $ensure_function with args: ${failure_args[*]}"
        run "$ensure_function" "${failure_args[@]}"
        assert_failure
        strip_ansi_from_output
        assert_output "✗ $expected_failure"
    fi
}

assert_death() {
    local error_message=$1
    assert_failure
    strip_ansi_from_output
    assert_output "✗ $error_message"
}

log_mock_call() {
    local name=$1
    local answer=$2
    shift 2
    puts "# 🤡 Called mocked $name $* -> $answer"
}

log_teardown() {
    puts "# 🧼 Running teardown step: $1"
}

log_step() {
    puts "# ► $*"
}