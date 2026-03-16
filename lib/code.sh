#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that relate to the code itself, where it is located, and how it is used.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

# meta::import ui

# jdvlib: --- END IMPORTS ---

# Use extra_level if you are calling this from included files
# rather than a script directly.
# Collapses repeated adjacent BASH_SOURCE entries to handle cases
# where scripts are sourced multiple times.
code::script_dir() {
    local -i extra_level=${1:-0}
    local -a collapsed_sources
    local last_source=
    local src
    for src in "${BASH_SOURCE[@]}"; do
        if [[ $src != "$last_source" ]]; then
            collapsed_sources+=("$src")
            last_source=$src
        fi
    done
    src=${collapsed_sources[1 + $extra_level]}
    if [[ -z $src ]]; then
        src=${collapsed_sources[-1]}
    fi
    local dir
    dir="$(cd "$(dirname "$src")" &>/dev/null && pwd)"
    echo "$dir"
}

code::is_sourced() {
    [[ "${BASH_SOURCE[1]}" != "${0}" ]]
}
