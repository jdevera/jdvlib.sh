#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to the system, its attributes and capabilities.
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

meta::import ui
meta::import func

# jdvlib: --- END IMPORTS ---


# @description Check if a command is available.
# @arg $1 string The command to check
# @exitcode 0 If the command is available
# @exitcode 1 If the command is not available
sys::has_command() {
    command -v "$1" &>/dev/null
}


# @description Ensure that the required commands are available
# If any of the commands are not available, the script will exit with an error
# that lists the missing commands.
#
# @arg $@ array The list of commands to check
sys::ensure_has_commands() {
    local missing=()
    local cmd
    for cmd in "$@"; do
        if ! sys::has_command "$cmd"; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        ui::die "This script requires the following commands but they are not installed: ${missing[*]}"
    fi
}

sys::is_in_path() {
    local dir=$1
    echo "$PATH" | tr ':' '\n' | grep -q "^${dir}$"
}

# @description Ensure that a directory is in the PATH
# @arg $1 string The directory to check
sys::ensure_in_path() {
    local dir=$1
    func::ensure sys::is_in_path "$dir" \
        "The directory $dir is not in the PATH" \
        "The directory $dir is in the PATH"
}

sys::is_debian() {
    [[ -f /etc/debian_version ]]
}

sys::ensure_debian() {
    func::ensure sys::is_debian \
        "This script is intended to run on a Debian-based system" \
        "This is a Debian-based system"
}

# @description Get arch (amd64 or arm64) on linux or macos
sys::get_arch() {
    local arch
    arch=$(uname -s)
    case $arch in
    Linux)
        dpkg --print-architecture
        ;;
    Darwin)
        uname -m
        ;;
    *)
        ui::die "Unsupported OS: $(uname -s)"
        ;;
    esac
}

sys::get_os() {
    local os
    os=$(uname -s)
    case $os in
    Linux)
        echo linux
        ;;
    Darwin)
        echo darwin
        ;;
    *)
        ui::die "Unsupported OS: $(uname -s)"
        ;;
    esac
}

sys::is_linux() {
    [[ $(uname -s) == Linux ]]
}

sys::is_macos() {
    [[ $(uname -s) == Darwin ]]
}

sys::ensure_macos() {
    func::ensure sys::is_macos \
        "This script is intended to run on a macOS system" \
        "This is a macOS system"
}

sys::ensure_linux() {
    func::ensure sys::is_linux \
        "This script is intended to run on a Linux system" \
        "This is a Linux system"
}

sys::run_as() {
    local user=$1
    shift
    if user::is_root; then
        su - "$user" -c "$*"
    else
        sudo -u "$user" "$@"
    fi
}

sys::is_docker_host() {
    sys::has_command docker && user::group_exists docker
}

sys::ensure_docker_host() {
    func::ensure sys::is_docker_host \
        "This script is intended to run on a Docker host" \
        "This is a Docker host"
}
