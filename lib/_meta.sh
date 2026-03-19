#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that support the library.
This module is the basis for imports, so there should never be an import of this file.
jdvlib:doc

# @section meta
# @description Functions that support the library.
#     This module is the basis for imports, so there should never be an import of this file.

# ☢️☢️☢️ WARNING: Do not import any other module here. ☢️☢️☢️

__JDVLIB_BUILD_DATE=${__JDVLIB_BUILD_DATE:-''}
__JDVLIB_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# @description Import a library module by name.
#   Sources the corresponding .sh file from the library directory.
#   If the library is compiled into a single file, this is a no-op.
#
# @arg $1 string The module name to import (without .sh extension).
#
# @exitcode 0 Always succeeds.
meta::import() {
    local file="$1"

    if meta::lib_is_compiled; then
        return
    fi

    # shellcheck source=/dev/null
    source "${__JDVLIB_PATH}/${file}.sh"
}

# @description Check if the library has been compiled into a single file.
#
# @noargs
#
# @exitcode 0 If the library is compiled.
# @exitcode 1 If the library is not compiled.
meta::lib_is_compiled() {
    [[ -n ${__JDVLIB_BUILD_DATE} ]]
}

# @description Check if the current module is being executed directly (not sourced).
#   Always returns false when the library is compiled.
#
# @noargs
#
# @exitcode 0 If the module is being run directly.
# @exitcode 1 If the module is sourced or the library is compiled.
meta::module_is_running() {
    if meta::lib_is_compiled; then
        return 1
    fi
    [[ "${BASH_SOURCE[1]}" == "${0}" ]]
}

# @description Iterate over each library module and apply an action.
#   Reads the module list from lib.sh and calls the action function
#   with the full path to each module file.
#
# @arg $1 string The function to call for each module file.
meta::for_each_library_module() {
    local action=$1
    local file
    while IFS= read -r file; do
        "$action" "$__JDVLIB_PATH/$file"
    done < <(awk '/^source / { print $2 }' "$__JDVLIB_PATH/lib.sh")
}

# @description Print the filesystem path to the library directory.
#   Returns an error if the library is compiled.
#
# @noargs
#
# @stdout The absolute path to the library directory.
#
# @exitcode 0 If the path was printed.
# @exitcode 1 If the library is compiled.
meta::library_path() {
    meta::lib_is_compiled && return 1
    echo "$__JDVLIB_PATH"
}
