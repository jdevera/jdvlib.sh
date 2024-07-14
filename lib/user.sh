#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to users and groups.
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

# jdvlib: --- END IMPORTS ---


user::is_root() {
    [[ $EUID -eq 0 ]]
}

user::ensure_root() {
    local reason=$1
    if ! user::is_root; then
        ui::die "This script must be run as root $reason"
    fi
    ui::reassure "Running as root"
}

user::exists() {
    local user=$1
    id "$user" &>/dev/null
}

user::ensure_exists() {
    local user=$1
    if ! user::exists "$user"; then
        ui::die "User $user does not exist"
    fi
    ui::reassure "User $user exists"
}

user::group_exists() {
    local group=$1
    if sys::is_macos; then
        dseditgroup -o read "$group" &>/dev/null
    else
        getent group "$group" &>/dev/null
    fi
    getent group "$group" &>/dev/null
}

user::ensure_group_exists() {
    local group=$1
    if ! group::group_exists "$group"; then
        ui::die "Group $group does not exist"
    fi
    ui::reassure "Group $group exists"
}

user::is_in_group() {
    local user=$1
    local group=$2
    groups "$user" | grep -q "\b$group\b"
}

user::ensure_in_group() {
    local user=$1
    local group=$2
    if ! user::is_in_group "$user" "$group"; then
        ui::die "User $user is not in group $group"
    fi
    ui::reassure "User $user is in group $group"
}

user::add_to_groups() {
    local user=$1
    shift
    for group in "$@"; do
        usermod -aG "$group" "$user"
    done
}

user::create() {
    local user=$1
    useradd -m -s /bin/bash "$user"
}