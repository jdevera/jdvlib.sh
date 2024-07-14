#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions to interact with the user.
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

meta::import ansi

# jdvlib: --- END IMPORTS ---

__ui_SIGN_DEATH="✗"
__ui_SIGN_OK="✔"
__ui_SIGN_FAIL="✗"
__ui_SIGN_INFO="ℹ"
__ui_SIGN_NOOP="∅"
__ui_SIGN_STEP="➜"
__ui_SIGN_DEPRECATED=""


ui::deco_message() {
    local sign=$1
    local color=$2
    local message=$3
    # shellcheck disable=SC2086 # Expansion of the color var is intended
    echo -e "$(ansi::ansi $color --bold "$sign") $(ansi::ansi --bold "$message")"
}

# Print a message to stderr and exit with a non-zero status
ui::die() {
    local sign=${sign:-$__ui_SIGN_DEATH}
    ui::deco_message "$sign" --red "$*" >&2
    exit 1
}

ui::ok() {
    local sign=${sign:-$__ui_SIGN_OK}
    ui::deco_message "$sign" --green "$*"
}

ui::fail() {
    local sign=${sign:-$__ui_SIGN_FAIL}
    ui::deco_message "$sign" --red "$*"
}

ui::info() {
    local sign=${sign:-$__ui_SIGN_INFO}
    ui::deco_message "$sign" "--blue" "$*"
}

ui::noop() {
    local sign=${sign:-$__ui_SIGN_NOOP}
    ui::deco_message "$sign" --yellow "$*"
}

ui::deprecate() {
    local function_name=$1
    local replacement=${2:-''}
    local sign=${sign:-$__ui_SIGN_DEPRECATED}
    local message=""
    if [[ -n $JDVLIB_DEBUG ]]; then
        local caller_file=${BASH_SOURCE[2]}
        local caller_line=${BASH_LINENO[1]}
        message+="${caller_file}:${caller_line}: "
    fi
    message+="The function $(ansi::ansi --italic "$function_name") is deprecated."
    if [[ -n $replacement ]]; then
        message+=" Use $(ansi::ansi --italic "$replacement") instead."
    fi
    ui::deco_message "$sign" --magenta-intense "$message"
}

ui::echo_step() {
    local prefix=${prefix:-''}
    local sign=${sign:-$__ui_SIGN_STEP}
    ui::deco_message "${prefix}${sign}" --cyan "$*"
}

ui::reassurance_required() {
    local required=${reassure:-'false'}
    [[ "$required" == 'true' || "$required" == '1' ]]
}

ui::reassure() {
    if ui::reassurance_required; then
        ui::ok "$*"
    fi
}

# Ask a question, and save the answer to a given var, with a default value
ui::ask() {
    # shellcheck disable=SC2155 # subshell return code is not used
    local ask_force=$(args::flag_value '-f' "$1")
    [[ $ask_force == true ]] && shift

    local question=$1
    local -n var=$2
    local default=$3
    # if the variable is already set, skip asking unless a -f flag is passed
    if [[ -n $var && $ask_force == false ]]; then
        return
    fi

    local arrow=${ASK_ARROW:-==>}

    local value
    read -r -p "$arrow $question [$default]: " value
    var=${value:-$default}
}
