#!/usr/bin/env bash


# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import ansi

# jdvlib: --- END IMPORTS ---

# @section ui
# @description Functions to interact with the user.

__ui_SIGN_DEATH="✗"
__ui_SIGN_OK="✔"
__ui_SIGN_FAIL="✗"
__ui_SIGN_INFO="ℹ"
__ui_SIGN_NOOP="∅"
__ui_SIGN_STEP="➜"
__ui_SIGN_DEPRECATED=""


# @description Print a decorated message with a colored sign and bold text.
#
# @arg $1 string The sign/icon to display.
# @arg $2 string The ANSI color flag for the sign (e.g. --red).
# @arg $3 string The message text.
#
# @stdout The formatted message.
ui::deco_message() {
    local sign=$1
    local color=$2
    local message=$3
    # shellcheck disable=SC2086 # Expansion of the color var is intended
    echo -e "$(ansi::style -n $color --bold "$sign") $(ansi::style -n --bold "$message")"
}

# @description Print an error message to stderr and exit with status 1.
#
# @arg $@ string The error message.
ui::die() {
    local sign=${sign:-$__ui_SIGN_DEATH}
    ui::deco_message "$sign" --red "$*" >&2
    exit 1
}

# @description Print a success message with a green checkmark.
#
# @arg $@ string The success message.
#
# @stdout The formatted success message.
ui::ok() {
    local sign=${sign:-$__ui_SIGN_OK}
    ui::deco_message "$sign" --green "$*"
}

# @description Print a failure message with a red cross.
#
# @arg $@ string The failure message.
#
# @stdout The formatted failure message.
ui::fail() {
    local sign=${sign:-$__ui_SIGN_FAIL}
    ui::deco_message "$sign" --red "$*"
}

# @description Print an informational message with a blue info sign.
#
# @arg $@ string The informational message.
#
# @stdout The formatted info message.
ui::info() {
    local sign=${sign:-$__ui_SIGN_INFO}
    ui::deco_message "$sign" "--blue" "$*"
}

# @description Print a no-op message with a yellow empty-set sign.
#
# @arg $@ string The no-op message.
#
# @stdout The formatted no-op message.
ui::noop() {
    local sign=${sign:-$__ui_SIGN_NOOP}
    ui::deco_message "$sign" --yellow "$*"
}

# @description Print a deprecation warning for a function.
#   Optionally logs to ~/.jdvlib-deprecations.log when JDVLIB_LOG_DEPRECATIONS is set.
#
# @arg $1 string The deprecated function name.
# @arg $2 string Optional replacement function name.
#
# @env JDVLIB_DEBUG string Show caller file and line when non-empty.
# @env JDVLIB_LOG_DEPRECATIONS string Log deprecations to a file when non-empty.
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
    local log_deprecations=${JDVLIB_LOG_DEPRECATIONS:-''}
    if [[ -n $log_deprecations && -z $BATS_VERSION ]]; then
        echo "$EPOCHSECONDS $function_name ${replacement:-'-'} ${BASH_SOURCE[2]}:${BASH_LINENO[1]}"\
            >> "$HOME/.jdvlib-deprecations.log"
    fi
    message+="The function $(ansi::style -n --italic "$function_name") is deprecated."
    if [[ -n $replacement ]]; then
        message+=" Use $(ansi::style -n --italic "$replacement") instead."
    fi
    ui::deco_message "$sign" --magenta-intense "$message" >&2
}

# @description Print a step message with a cyan arrow sign.
#
# @arg $@ string The step message.
#
# @stdout The formatted step message.
ui::echo_step() {
    local prefix=${prefix:-''}
    local sign=${sign:-$__ui_SIGN_STEP}
    ui::deco_message "${prefix}${sign}" --cyan "$*"
}

# @description Check if reassurance messages should be displayed.
#   Returns true when the `reassure` variable is set to "true" or "1".
#
# @noargs
#
# @env reassure string Controls whether reassurance messages are shown.
#
# @exitcode 0 If reassurance is required.
# @exitcode 1 Otherwise.
ui::reassurance_required() {
    local required=${reassure:-'false'}
    [[ "$required" == 'true' || "$required" == '1' ]]
}

# @description Print a reassurance message if reassurance is enabled.
#   Only produces output when the `reassure` variable is "true" or "1".
#
# @arg $@ string The reassurance message.
#
# @see ui::reassurance_required()
ui::reassure() {
    if ui::reassurance_required; then
        ui::ok "$*"
    fi
}

# @description Ask the user a question and store the answer in a variable.
#   If the variable already has a value, the prompt is skipped unless -f is passed.
#
# @option -f Force asking even if the variable is already set.
# @arg $1 string The question to display.
# @arg $2 string The variable name (nameref) to store the answer in.
# @arg $3 string The default value if the user presses Enter.
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
