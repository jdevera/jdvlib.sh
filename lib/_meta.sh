#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that support the library.
This module is the basis for imports, so there should never be an import of this file.
jdvlib:doc

__JDVLIB_BUILD_DATE=${__JDVLIB_BUILD_DATE:-''}
__JDVLIB_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

meta::import() {
    local file="$1"

    if meta::lib_is_compiled || meta::is_compiling; then
        return
    fi

    # shellcheck source=/dev/null
    source "${__JDVLIB_PATH}/${file}.sh"
}

meta::lib_is_compiled() {
    [[ -n ${__JDVLIB_BUILD_DATE} ]]
}

meta::is_compiling() {
    [[ ${__jdvlib_compiling:-'0'} != '0' ]]
}

meta::module_is_running() {
    if meta::lib_is_compiled; then
        return 1
    fi
    [[ "${BASH_SOURCE[1]}" == "${0}" ]]
}
