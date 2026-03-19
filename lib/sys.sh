#!/usr/bin/env bash


# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import ui
meta::import func
meta::import args

# jdvlib: --- END IMPORTS ---

# @section sys
# @description Functions related to the system, its attributes and capabilities.

# @description Check if a command is available.
# @arg $1 string The command to check
# @exitcode 0 If the command is available
# @exitcode 1 If the command is not available
sys::has_command() {
    args::ensure_num_args 1 \
        'echo sys::has_command takes 1 arg' "$@"
    command -v "$1" &>/dev/null
}


# @description Run the first existing command from a list
# @arg $@ string Command names, optionally followed by -- and arguments
sys::run_first_of() {
    func::call_first_matching sys::has_command "$@"
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
        ui::die "These commands are required but not found: ${missing[*]}"
    fi
}

# @description Check if a directory is in the PATH.
#
# @arg $1 string The directory to check.
#
# @exitcode 0 If the directory is in the PATH.
# @exitcode 1 If the directory is not in the PATH.
sys::is_in_path() {
    local dir=$1
    echo "$PATH" | tr ':' '\n' | grep -q "^${dir}$"
}

# @description Ensure that a directory is in the PATH
# @arg $1 string The directory to check
sys::ensure_in_path() {
    local dir=$1
    func::ensure sys::is_in_path \
        "The directory $dir is not in the PATH" \
        "The directory $dir is in the PATH" \
        "$dir"
}

# @description Check if the system is Debian-based.
#
# @noargs
#
# @exitcode 0 If running on a Debian-based system.
# @exitcode 1 Otherwise.
sys::is_debian() {
    [[ -f /etc/debian_version ]]
}

# @description Ensure the system is Debian-based, exit with an error if not.
#
# @noargs
sys::ensure_debian() {
    func::ensure sys::is_debian \
        "This is intended to run on a Debian-based system" \
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

# @description Get the operating system name in lowercase.
#
# @noargs
#
# @stdout "linux" or "darwin".
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

# @description Check if the system is Linux.
#
# @noargs
#
# @exitcode 0 If running on Linux.
# @exitcode 1 Otherwise.
sys::is_linux() {
    [[ $(uname -s) == Linux ]]
}

# @description Check if the system is macOS.
#
# @noargs
#
# @exitcode 0 If running on macOS.
# @exitcode 1 Otherwise.
sys::is_macos() {
    [[ $(uname -s) == Darwin ]]
}

# @description Ensure the system is macOS, exit with an error if not.
#
# @noargs
sys::ensure_macos() {
    func::ensure sys::is_macos \
        "This is intended to run on a macOS system" \
        "This is a macOS system"
}

# @description Ensure the system is Linux, exit with an error if not.
#
# @noargs
sys::ensure_linux() {
    func::ensure sys::is_linux \
        "This is intended to run on a Linux system" \
        "This is a Linux system"
}

# @description Get the macOS product version string.
#   Requires macOS; exits with an error on other platforms.
#
# @noargs
#
# @stdout The macOS version (e.g. "14.3.1").
sys::macos_version() {
    sys::ensure_macos
    sw_vers -productVersion
}

# @description Get the macOS marketing code name for the current version.
#
# @noargs
#
# @stdout The macOS code name (e.g. "Sonoma").
#
# @exitcode 0 If the version is recognized.
# @exitcode 1 If the version is unknown.
sys::macos_code_name() {
    local version
    version=$(sys::macos_version)
    case $version in
        10.10*) echo "Yosemite" ;;
        10.11*) echo "El Capitan" ;;
        10.12*) echo "Sierra" ;;
        10.13*) echo "High Sierra" ;;
        10.14*) echo "Mojave" ;;
        10.15*) echo "Catalina" ;;
        11*) echo "Big Sur" ;;
        12*) echo "Monterey" ;;
        13*) echo "Ventura" ;;
        14*) echo "Sonoma" ;;
        *)
            echo "Unknown macOS version: $version"
            return 1
            ;;
    esac
}

# @description Run a command as a different user.
#   If the current user matches, runs directly. If root, uses su.
#   Otherwise, uses sudo.
#
# @arg $1 string The username to run as.
# @arg $@ string The command and its arguments.
sys::run_as() {
    local user=$1
    shift
    local -a command=()
    if [[ $USER == "$user" ]]; then
        command=("$@")
    elif user::is_root; then
        command=(su - "$user" -c "$*")
    else
        command=(sudo -u "$user" "$@")
    fi
    "${command[@]}"
}

# @description Check if this host has Docker installed and configured.
#   Checks for the docker command and the docker group.
#
# @noargs
#
# @exitcode 0 If Docker is available.
# @exitcode 1 If Docker is not available.
sys::is_docker_host() {
    sys::has_command docker && user::group_exists docker
}

# @description Ensure this is a Docker host, exit with an error if not.
#
# @noargs
sys::ensure_docker_host() {
    func::ensure sys::is_docker_host \
        "This is intended to run on a Docker host" \
        "This is a Docker host"
}

# @description Check if the Docker daemon is running and accessible.
#
# @noargs
#
# @exitcode 0 If Docker is running.
# @exitcode 1 If Docker is not running.
sys::is_docker_running() {
    docker info &>/dev/null
}

# @description Ensure the Docker daemon is running, exit with an error if not.
#
# @noargs
sys::ensure_docker_running() {
    func::ensure sys::is_docker_running \
        "Docker daemon is not running" \
        "Docker daemon is running"
}
