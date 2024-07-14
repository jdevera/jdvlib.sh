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
[[ ${__jdvlib_compiling:-'0'} == '0' ]] && \
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import ui

# jdvlib: --- END IMPORTS ---

# A function that can be used to ensure boolean functions return true.
#
# This is mostly intended to be used to create ensure_ functions in the library.
#
# @arg $1 string The function to run
# @arg $2 string The error message to display if the function returns false
# @arg $3 string The reassurance message to display if the function returns true
# @arg $@ array The arguments to pass to the function
#
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

func::list_functions_in_file() {
    local file=$1
    local extdebug_was_off=0
    if ! shopt -q extdebug; then
        shopt -s extdebug
        extdebug_was_off=1
    fi
    local file_path
    file_path=$( cd "$( dirname "$file" )" &> /dev/null && pwd )/$(basename "$file")
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    func::list_functions_in_file "$1"
fi