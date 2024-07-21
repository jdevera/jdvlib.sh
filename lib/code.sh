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
[[ ${__jdvlib_compiling:-'0'} == '0' ]] && \
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

# meta::import ui

# jdvlib: --- END IMPORTS ---

# Use extra_level if you are calling this from included files
# rather than a script directly.
code::script_dir() {
    local -i extra_level=${1:-0}
    local script_dir
    local source=${BASH_SOURCE[1 + extra_level]}
    script_dir=$(cd "$(dirname "${source}")" &>/dev/null && pwd)
    echo "$script_dir"
}

code::is_sourced() {
    [[ "${BASH_SOURCE[1]}" != "${0}" ]]
}