#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions used to manage environment variables.
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


# Load a .env file from the current directory or from the specified path
# @arg $1 string The path to the .env file (optional)
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
            sed -i -e "/^$1=/d" "$env_file"
        fi
        shift
    done
}

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


env::ensure_is_set() {
    local -n __var=$1
    if [[ -z $__var ]]; then
        ui::die "Variable not set: $1"
    fi
    ui::reassure "Variable is set: $1"
}

