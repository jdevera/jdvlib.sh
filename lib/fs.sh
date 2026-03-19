#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to the filesystem. Existance, permissions, etc.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

meta::import sys
meta::import ui
meta::import func

# jdvlib: --- END IMPORTS ---

# @section fs
# @description Functions related to the filesystem, including existence checks, permissions, and mount detection.

# @description Check if a file is owned by a specific user.
#   Works on both Linux and macOS.
#
# @arg $1 string The file path.
# @arg $2 string The username to check ownership against.
#
# @exitcode 0 If the file is owned by the user.
# @exitcode 1 If the file is not owned by the user.
fs::is_owned_by_user() {
    local file=$1
    local user=$2
    local -a stat_args=()
    if sys::is_linux; then
        stat_args+=(-c %U)
    elif sys::is_macos; then
        stat_args+=(-f %Su)
    else
        ui::die "Unsupported OS"
    fi
    [[ $(stat "${stat_args[@]}" "$file") == "$user" ]]

}

# @description Ensure that a file exists, exit with an error if it does not.
#
# @arg $1 string The file path to check.
fs::ensure_file_exists() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        ui::die "File $file does not exist"
    fi
    ui::reassure "File $file exists"
}

# @description Ensure that a directory exists, exit with an error if it does not.
#
# @arg $1 string The directory path to check.
fs::ensure_dir_exists() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        ui::die "Directory $dir does not exist"
    fi
    ui::reassure "Directory $dir exists"
}

# @description Check if a path resides on a CIFS or NFS remote mount.
#   Walks up the directory tree looking for a mountpoint and checks
#   whether it is a remote filesystem type.
#
# @arg $1 string The file or directory path to check.
#
# @exitcode 0 If the path is on a remote mount.
# @exitcode 1 If the path is not on a remote mount.
fs::is_in_remote_mount() {
    local path=$1
    if [[ ! -d $path ]]; then
        path=$(dirname "$path")
    fi
    path=$(realpath "$path")
    while [[ $path != '/' ]]; do
        if mountpoint -q "$path"; then
            # check if the mount is cifs or nfs
            if mount | grep -qE "on $path type [cifs|nfs]"; then
                return 0
            else
                return 1
            fi
        fi
        path=$(dirname "$path")
    done
    return 1
}

# @description Ensure that a path is on a remote mount, exit with an error if not.
#
# @arg $1 string The path to check.
fs::ensure_in_remote_mount() {
    local path=$1
    func::ensure fs::is_in_remote_mount \
        "Path $path is not in a remote mount" \
        "Path $path is in a remote mount" \
        "$path"
}

# @description Check if a user can write to a directory.
#   Tests write access by attempting to create a temporary file as the user.
#
# @arg $1 string The username.
# @arg $2 string The directory path.
#
# @exitcode 0 If the user can write to the directory.
# @exitcode 1 If the user cannot write to the directory.
fs::can_user_write_to_dir() {
    local user=$1
    local dir=$2
    local tmp_file
    tmp_file="$(mktemp -u "$dir/test_write.XXXXXX")"
    if sys::run_as "$user" touch "$tmp_file"; then
        sys::run_as "$user" rm "$tmp_file"
        return 0
    else
        return 1
    fi
}
