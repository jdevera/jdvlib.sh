#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to the filesystem. Existance, permissions, etc.
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

meta::import sys
meta::import ui

# jdvlib: --- END IMPORTS ---


fs::is_owned_by_user() {
    local file=$1
    local user=$2
    [[ $(stat -c %U "$file") == "$user" ]]
}


fs::ensure_file_exists() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        ui::die "File $file does not exist"
    fi
    ui::reassure "File $file exists"
}

fs::ensure_dir_exists() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        ui::die "Directory $dir does not exist"
    fi
    ui::reassure "Directory $dir exists"
}

# check if the given file is in a cifs or nfs mount
# admit also nested paths
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

fs::ensure_in_remote_mount() {
    local path=$1
    if ! fs::is_in_remote_mount "$path"; then
        ui::die "Path $path is not in a remote mount"
    fi
    ui::reassure "Path $path is in a remote mount"
}

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
