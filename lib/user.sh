#!/usr/bin/env bash


# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import func
meta::import sys
meta::import ui

# jdvlib: --- END IMPORTS ---

# @section user
# @description Functions related to users and groups.

# @description Check if the current user is root.
#
# @noargs
#
# @exitcode 0 If the effective user ID is 0.
# @exitcode 1 Otherwise.
user::is_root() {
    [[ $EUID -eq 0 ]]
}

# @description Ensure the script is running as root, exit with an error if not.
#
# @arg $1 string A reason string appended to the error message.
user::ensure_root() {
    local reason=$1
    func::ensure user::is_root \
        "This script must be run as root $reason" \
        "Running as root"
}

# @description Check if a user account exists on the system.
#
# @arg $1 string The username to check.
#
# @exitcode 0 If the user exists.
# @exitcode 1 If the user does not exist.
user::exists() {
    local user=$1
    id "$user" &>/dev/null
}

# @description Ensure a user account exists, exit with an error if not.
#
# @arg $1 string The username to check.
user::ensure_exists() {
    local user=$1
    func::ensure user::exists \
        "User $user does not exist" \
        "User $user exists" \
        "$user"
}

# @description Check if a group exists on the system.
#   Uses dseditgroup on macOS and getent on Linux.
#
# @arg $1 string The group name to check.
#
# @exitcode 0 If the group exists.
# @exitcode 1 If the group does not exist.
user::group_exists() {
    local group=$1
    if sys::is_macos; then
        dseditgroup -o read "$group" &>/dev/null
    else
        getent group "$group" &>/dev/null
    fi
}

# @description Ensure a group exists, exit with an error if not.
#
# @arg $1 string The group name to check.
user::ensure_group_exists() {
    local group=$1
    func::ensure user::group_exists \
        "Group $group does not exist" \
        "Group $group exists" \
        "$group"
}

# @description Check if a user belongs to a group.
#
# @arg $1 string The username.
# @arg $2 string The group name.
#
# @exitcode 0 If the user is in the group.
# @exitcode 1 If the user is not in the group.
user::is_in_group() {
    local user=$1
    local group=$2
    id -nG "$user" | tr ' ' '\n' | grep -qxF "$group"
}

# @description Ensure a user belongs to a group, exit with an error if not.
#
# @arg $1 string The username.
# @arg $2 string The group name.
user::ensure_in_group() {
    local user=$1
    local group=$2
    func::ensure user::is_in_group \
        "User $user is not in group $group" \
        "User $user is in group $group" \
        "$user" "$group"
}

# @description Add a user to one or more groups.
#
# @arg $1 string The username.
# @arg $@ string The group names to add the user to.
user::add_to_groups() {
    local user=$1
    shift
    for group in "$@"; do
        usermod -aG "$group" "$user"
    done
}

# @description Create a new user account with a home directory and bash shell.
#
# @arg $1 string The username to create.
user::create() {
    local user=$1
    useradd -m -s /bin/bash "$user"
}
