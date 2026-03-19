#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to functions and function management.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import ui

# jdvlib: --- END IMPORTS ---

# @section func
# @description Functions related to functions and function management.

# @description Check if a function exists
# @arg $1 string The function name to check
func::exists() {
    declare -f -F "$1" >/dev/null
}

# @description Ensure a boolean function returns true, exit with an error otherwise.
#   Intended to be used to create ensure_ wrapper functions in the library.
#
# @arg $1 string The function to run.
# @arg $2 string The error message to display if the function returns false.
# @arg $3 string The reassurance message to display if the function returns true.
# @arg $@ string The arguments to pass to the function.
func::ensure() {
    local func=$1
    local error_message=$2
    local reasurance_message=$3
    shift 3

    if ! "$func" "$@"; then
        ui::die "$error_message"
    fi
    ui::reassure "$reasurance_message"
}

# @description Find the first candidate that passes a checker and call it
# @arg $1 string The checker function to test each candidate
# @arg $@ string Candidate names, optionally followed by -- and arguments
func::call_first_matching() {
    local checker=$1
    shift
    local callable=
    while [[ $# -gt 0 ]]; do
        [[ $1 == '--' ]] && return 1
        if "$checker" "$1"; then
            callable="$1"
            shift
            break
        fi
        shift
    done

    [[ -z $callable ]] && return 1

    # Discard remaining candidates until -- or end
    while [[ $# -gt 0 ]]; do
        if [[ $1 == '--' ]]; then
            shift
            break
        fi
        shift
    done

    "$callable" "$@"
}

# @description Call the first existing function from a list
# @arg $@ string Function names, optionally followed by -- and arguments
func::call_first_of() {
    func::call_first_matching func::exists "$@"
}

# @description List all functions defined in a shell script file.
#   Sources the file in a subshell and inspects declared functions to find
#   those whose definition originates from the given file.
#
# @arg $1 string The path to the shell script file.
#
# @stdout One function name per line.
#
# @exitcode 0 On success.
# @exitcode 1 If the file does not exist.
func::list_functions_in_file() {
    local file=$1
    local extdebug_was_off=0
    if ! shopt -q extdebug; then
        shopt -s extdebug
        extdebug_was_off=1
    fi
    local file_path
    file_path=$( cd "$( dirname "$file" )" &> /dev/null && pwd )/$(basename "$file")
    if [[ ! -f $file_path ]]; then
        ui::fail "meta::list_functions_in_file: The file '$file' does not exist."
        return 1
    fi
    (
        # shellcheck source=/dev/null
        . "$file_path"
        local funct location _
        for funct in $(declare -F | awk '{print $3}'); do
            read -r _ _ location < <(declare -F "$funct")
            if [[ $location == "$file_path" ]]; then
                echo "$funct"
            fi
        done
    )
    if [[ $extdebug_was_off -eq 1 ]]; then
        shopt -u extdebug
    fi
}

if meta::module_is_running; then
    func::list_functions_in_file "$1"
fi
