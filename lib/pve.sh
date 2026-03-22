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

# jdvlib: --- END IMPORTS ---

# @section pve
# @description Functions related to Proxmox Virtual Environment (PVE).

# @description Check if the current host is a Proxmox VE server.
#
# @noargs
#
# @exitcode 0 If running on a PVE host.
# @exitcode 1 If not running on a PVE host.
pve::is_pve() {
    [[ -f /usr/bin/pvesh ]]
}

# @description Ensure the current host is a PVE server, exit with an error if not.
#
# @noargs
pve::ensure_pve() {
    if ! pve::is_pve; then
        ui::die "This is not a Proxmox Virtual Environment (PVE) host"
    fi
    ui::reassure "This is a Proxmox Virtual Environment (PVE) host"
}

# @description Check if the current environment is an LXC container.
#
# @noargs
#
# @exitcode 0 If running inside an LXC container.
# @exitcode 1 If not running inside an LXC container.
pve::is_lxc() {
    [[ -f /proc/1/environ ]] &&
        tr '\0' '\n' < /proc/1/environ 2>/dev/null | grep -qx 'container=lxc'
}

# @description Ensure the current environment is an LXC container, exit with an error if not.
#
# @noargs
pve::ensure_lxc() {
    if ! pve::is_lxc; then
        ui::die "This is not a LXC container"
    fi
    ui::reassure "This is a LXC container"
}
