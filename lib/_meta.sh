#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that support the library.
This module is the basis for imports, so there should never be an import of this file.
jdvlib:doc

# ☢️☢️☢️ WARNING: Do not import any other module here. ☢️☢️☢️

__JDVLIB_BUILD_DATE=${__JDVLIB_BUILD_DATE:-''}
__JDVLIB_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

meta::import() {
    local file="$1"

    if meta::lib_is_compiled; then
        return
    fi

    # shellcheck source=/dev/null
    source "${__JDVLIB_PATH}/${file}.sh"
}

meta::lib_is_compiled() {
    [[ -n ${__JDVLIB_BUILD_DATE} ]]
}

meta::module_is_running() {
    if meta::lib_is_compiled; then
        return 1
    fi
    [[ "${BASH_SOURCE[1]}" == "${0}" ]]
}

meta::for_each_library_module() {
    local action=$1
    local file
    while IFS= read -r file; do
        "$action" "$__JDVLIB_PATH/$file"
    done < <(awk '/^source / { print $2 }' "$__JDVLIB_PATH/lib.sh")
}

meta::library_path() {
    meta::lib_is_compiled && return 1
    echo "$__JDVLIB_PATH"
}
