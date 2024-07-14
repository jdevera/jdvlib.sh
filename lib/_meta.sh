#!/usr/bin/env bash


__JDVLIB_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

meta::import() {
    local file="$1"
    # shellcheck source=/dev/null
    [[ ${__jdvlib_compiling:-'0'} == '0' ]] && \
        source "${__JDVLIB_PATH}/${file}.sh"
}