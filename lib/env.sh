#!/usr/bin/env bash


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

# @section env
# @description Functions used to manage environment variables.

# @description Load a .env file into the current shell environment.
#   Sources the file at the given path, or .env in the current directory
#   if no path is specified.
#
# @option -f string Path to the .env file (default: .env).
env::dotenv_load() {
    local env_file
    if [[ $1 == '-f' ]]; then
        env_file=$2
        shift
        shift
    else
        env_file=.env
    fi
    if [[ -f $env_file ]]; then
        # shellcheck disable=SC1090
        source "$env_file"
    fi
}


# @description Delete one or more variables from a .env file.
#   Removes lines matching the given variable names from the file.
#
# @option -f string Path to the .env file (default: ./.env).
# @arg $@ string Variable names to delete.
env::dotenv_delete() {
    local env_file
    if [[ $1 == '-f' ]]; then
        env_file=$2
        shift
        shift
    else
        env_file='./.env'
    fi
    if [[ ! -f $env_file ]]; then
        return
    fi
    while [[ $# -gt 0 ]]; do
        if grep -q "^$1=" "$env_file"; then
            grep -v "^$1=" "$env_file" > "$env_file.tmp" && mv "$env_file.tmp" "$env_file"
        fi
        shift
    done
}

# @description Save one or more variables to a .env file.
#   Writes the current value of each named variable to the file,
#   replacing any existing entry for the same variable.
#
# @option -f string Path to the .env file (default: .env).
# @arg $@ string Variable names to save.
env::dotenv_save() {
    local env_file
    if [[ $1 == '-f' ]]; then
        env_file=$2
        shift
        shift
    else
        env_file=.env
    fi
    while [[ $# -gt 0 ]]; do
        local -n ref=$1
        # if the var exists, remove it from the file first
        env::dotenv_delete -f "$env_file" "$1"
        echo "$1=${ref}" >>"$env_file"
        shift
    done
}


# @description Ensure that a variable is set and non-empty.
#   Exits with an error if the variable is empty.
#
# @arg $1 string The name of the variable to check (not the value).
#
# @exitcode 0 If the variable is set.
# @exitcode 1 Exits via ui::die if the variable is empty.
env::ensure_is_set() {
    local -n __var=$1
    if [[ -z $__var ]]; then
        ui::die "Variable not set: $1"
    fi
    ui::reassure "Variable is set: $1"
}
