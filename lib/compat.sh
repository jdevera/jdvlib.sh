#!/usr/bin/env bash

: <<'jdvlib:doc'
This is a compatibility layer for deprecated functions.  It is intended to be
used when refactoring code to use the new functions.  It will be removed in the
future.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
[[ ${__jdvlib_compiling:-'0'} == '0' ]] && \
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

# shellcheck source=./ansi.sh
meta::import ansi
# shellcheck source=./args.sh
meta::import args
meta::import code
meta::import env
meta::import env
meta::import fs
meta::import pve
meta::import sys
meta::import text
meta::import ui
meta::import user
meta::import text

# jdvlib: --- END IMPORTS ---


deco_message() {
    ui::deprecate "deco_message" "ui::deco_message"
    ui::deco_message "$@"
}

die() {
    ui::deprecate "die" "ui::die"
    ui::die "$@"
}

ok() {
    ui::deprecate "ok" "ui::ok"
    ui::ok "$@"
}

fail() {
    ui::deprecate "fail" "ui::fail"
    ui::fail "$@"
}

info() {
    ui::deprecate "info" "ui::info"
    ui::info "$@"
}

noop() {
    ui::deprecate "noop" "ui::noop"
    ui::noop "$@"
}

echo_step() {
    ui::deprecate "echo_step" "ui::echo_step"
    ui::echo_step "$@"
}

ensure_root() {
    ui::deprecate "ensure_root" "user::ensure_root"
    local reason=$1
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root $reason"
    fi
}

ensure_pve() {
    ui::deprecate "ensure_pve" "pve::ensure_pve"
    pve::ensure_pve
}

check_help_arg() {
    ui::deprecate "check_help_arg" "args::check_help_arg"
    args::check_help_arg "$@"
}

ensure_num_args() {
    ui::deprecate "ensure_num_args" "args::ensure_num_args"
    args::ensure_num_args "$@"
}

has_command() {
    ui::deprecate "has_command" "sys::has_command"
    sys::has_command "$@"
}

ensure_has_commands() {
    ui::deprecate "ensure_has_commands" "sys::ensure_has_commands"
    sys::ensure_has_commands "$@"
}

script_dir() {
    ui::deprecate "script_dir" "code::script_dir"
    code::script_dir
}

ensure_in_path() {
    ui::deprecate "ensure_in_path" "sys::ensure_in_path"
    sys::ensure_in_path "$@"
}

ensure_debian() {
    ui::deprecate "ensure_debian" "sys::ensure_debian"
    sys::ensure_debian
}

get_arch() {
    ui::deprecate "get_arch" "sys::get_arch"
    sys::get_arch
}

get_os() {
    ui::deprecate "get_os" "sys::get_os"
    sys::get_os
}

is_linux() {
    ui::deprecate "is_linux" "sys::is_linux"
    sys::is_linux
}

is_macos() {
    ui::deprecate "is_macos" "sys::is_macos"
    sys::is_macos
}

ask() {
    ui::deprecate "ask" "ui::ask"
    ui::ask "$@"
}

dotenv_load() {
    ui::deprecate "dotenv_load" "env::dotenv_load"
    env::dotenv_load "$@"
}

load_env() {
    ui::deprecate "load_env" "dotenv_load"
    dotenv_load -f "$@"
}

dotenv_delete() {
    ui::deprecate "dotenv_delete" "env::dotenv_delete"
    env::dotenv_delete "$@"
}

dotenv_save() {
    ui::deprecate "dotenv_save" "env::dotenv_save"
    env::dotenv_save "$@"
}

ensure_docker_host() {
    ui::deprecate "ensure_docker_host" "sys::ensure_docker_host"
    sys::ensure_docker_host
}

is_owned_by_user() {
    ui::deprecate "is_owned_by_user" "fs::is_owned_by_user"
    fs::is_owned_by_user "$@"
}

ensure_file_exists() {
    ui::deprecate "ensure_file_exists" "fs::ensure_file_exists"
    local verbose
    verbose=$(flag_value -v "$1")
    [[ $verbose == true ]] && shift
    reassure=$verbose fs::ensure_file_exists "$@"
}

ensure_dir_exists() {
    ui::deprecate "ensure_dir_exists" "fs::ensure_dir_exists"
    local verbose
    verbose=$(flag_value -v "$1")
    [[ $verbose == true ]] && shift
    reassure=$verbose fs::ensure_dir_exists "$@"
}

ensure_var_is_set() {
    ui::deprecate "ensure_var_is_set" "env::ensure_is_set"
    local verbose
    verbose=$(flag_value -v "$1")
    [[ $verbose == true ]] && shift
    reassure=$verbose env::ensure_is_set "$@"
}

flag_value() {
    ui::deprecate "flag_value" "args::flag_value"
    args::flag_value "$@"
}

is_in_remote_mount() {
    ui::deprecate "is_in_remote_mount" "fs::is_in_remote_mount"
    fs::is_in_remote_mount "$@"
}

ensure_in_remote_mount() {
    ui::deprecate "ensure_in_remote_mount" "fs::ensure_in_remote_mount"
    local verbose
    verbose=$(flag_value -v "$1")
    [[ $verbose == true ]] && shift

    reassure=$verbose fs::ensure_in_remote_mount "$@"
}

print_aligned() {
    ui::deprecate "print_aligned" "text::print_aligned"
    text::print_aligned "$@"
}

is_lxc() {
    ui::deprecate "is_lxc" "pve::is_lxc"
    pve::is_lxc
}

run_as() {
    ui::deprecate "run_as" "sys::run_as"
    sys::run_as "$@"
}

can_user_write_to_dir() {
    ui::deprecate "can_user_write_to_dir" "fs::can_user_write_to_dir"
    fs::can_user_write_to_dir "$@"
}

replace_between_markers() {
    ui::deprecate "replace_between_markers" "text::replace_between_markers_legacy"
    text::replace_between_markers_legacy "$@"
}
