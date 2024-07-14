#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that relate to the code itself, where it is located, and how it is used.
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


code::script_dir() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[1]}")" &>/dev/null && pwd)
    echo "$script_dir"
}
