#!/usr/bin/env bash


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

# @section code
# @description Functions that relate to the code itself, where it is located, and how it is used.

# @description Get the directory of the calling script.
#   Use extra_level if you are calling this from included files
#   rather than a script directly.
#   Collapses repeated adjacent BASH_SOURCE entries to handle cases
#   where scripts are sourced multiple times.
#
# @arg $1 number Optional extra stack level offset (default: 0).
#
# @stdout The absolute path to the directory containing the calling script.
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

# @description Check if the current script is being sourced rather than executed directly.
#
# @noargs
#
# @exitcode 0 If the script is being sourced.
# @exitcode 1 If the script is being executed directly.
code::is_sourced() {
    [[ "${BASH_SOURCE[1]}" != "${0}" ]]
}
