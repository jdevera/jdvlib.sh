#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions related to Proxmox Virtual Environment (PVE).
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

meta::import ui

# jdvlib: --- END IMPORTS ---


pve::is_pve() {
    [[ -f /usr/bin/pvesh ]]
}

pve::ensure_pve() {
    if ! pve::is_pve; then
        ui::die "This is not a Proxmox Virtual Environment (PVE) host"
    fi
    ui::reassure "This is a Proxmox Virtual Environment (PVE) host"
}

pve::is_lxc() {
    [[ -f /proc/1/environ ]] &&
        grep -q container=lxc /proc/1/environ
}

pve::ensure_lxc() {
    if ! pve::is_lxc; then
        ui::die "This is not a LXC container"
    fi
    ui::reassure "This is a LXC container"
}
