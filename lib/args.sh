#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions to help with parsing and validation of command line arguments.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all of the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
[[ ${__jdvlib_compiling:-'0'} == '0' ]] && \
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

# meta::import ui

# jdvlib: --- END IMPORTS ---


# @description If any of the arguments are -h or --help, run the help function and exit.
# It does not do anything with the rest of the arguments.
#
# @arg $1 function The help function to call if -h or --help is passed
# @example
#     args::check_help_arg help "$@"
args::check_help_arg() {
    local help_function=$1
    shift
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            "$help_function"
            exit 0
        fi
        shift
    done
}

# @description
#   Ensure the expected number of arguments was passed to a script or function.
#   If the number of arguments is incorrect, the usage function is called and
#   the script exits.
# @arg $1 number The expected number of arguments
# @arg $2 function The usage function to call if the number of arguments is incorrect
# @example
#     args::ensure_num_args 3 usage "$@"
args::ensure_num_args() {
    local expected=$1 # Expected number of arguments
    local usage_function=$2    # Usage function to call if the number of arguments is incorrect
    shift 2
    args::ensure_num_args_between "$expected" "$expected" "$usage_function" "$@"
}

# @description
#   Ensure the number of arguments is between a minimum and maximum.
#   If the number of arguments is incorrect, the usage function is called and
#   the script exits.
#   The max can be set to -1 to indicate no maximum.
args::ensure_num_args_between() {
    local min=$1
    local max=$2
    local usage_function=$3
    shift 3
    local num_args=$#
    if [[ $num_args -lt $min || ($max -ne -1 && $num_args -gt $max) ]]; then
        $usage_function
        exit 1
    fi
}

args::flag_value() {
    local expected=$1
    local value=$2
    if [[ $expected == "$value" ]]; then
        echo true
    else
        echo false
    fi
}

# @description
#   Find if a given flag is present in the arguments. If the flag is found, set the
#   variable referenced by the second parameter to true, and store the rest of the
#   arguments in the array referenced by the third parameter.
#   If the flag is not found, set the variable to false and store all the arguments
#   in the array.
#   This array can then be used with set -- on the calling side to reset the arguments
#   and continue processing.
# @arg $1 string The flag to search for
# @arg $2 string The variable (nameref) to set to true or false if the flag is found or not
# @arg $3 array The array (nameref) to store the remaining arguments in
# @example
#   declare flag_found        # This variable will be set to true or false
#   declare -a rest_args      # This array will store the remaining arguments
#   args::get_flag_value --flag flag_found rest_args "$@"
#   set -- "${rest_args[@]}"  # Reset the arguments
#   # If the script is called with args: a --flag b c d, the above code will set
#   # flag_found to true and rest_args to (a b c d)
args::get_flag_value() {
    local flag=$1
    local -n __jdvlib_dest=$2
    local -n __jdvlib_args=$3
    shift 3
    __jdvlib_args=()
    local found=false
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "$flag" ]]; then
            found=true
        else
            __jdvlib_args+=("$1")
        fi
        shift
    done
    __jdvlib_dest=$found
}