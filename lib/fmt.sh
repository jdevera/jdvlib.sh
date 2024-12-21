#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions to format data.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
[[ ${__jdvlib_compiling:-'0'} == '0' ]] &&
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_meta.sh"

meta::import ui
meta::import sys

# jdvlib: --- END IMPORTS ---

declare -gA __BYTES_CONVERSION_TABLE=(
    [B]=1
    [KB]=1024
    [MB]=1048576
    [GB]=1073741824
    [TB]=1099511627776
    [PB]=1125899906842624
    [EB]=1152921504606846976
)

declare -ga __BYTES_UNITS=(
    B KB MB GB TB PB EB
)

fmt::__deps() {
    sys::ensure_has_commands awk
}

fmt::__get_unit_factor() {
    local unit=$1

    if [[ -z "${__BYTES_CONVERSION_TABLE[$unit]}" ]]; then
        ui::die "Invalid unit in fmt::__get_unit_factor: $unit"
    fi
    echo "${__BYTES_CONVERSION_TABLE[$unit]}"
}

fmt::__get_unit_magnitude() {
    local unit=$1

    if [[ -z "${__BYTES_CONVERSION_TABLE[$unit]}" ]]; then
        ui::die "Invalid unit in fmt::__get_unit_magnitude: $unit"
    fi

    local magnitude
    for magnitude in "${!__BYTES_UNITS[@]}"; do
        if [[ "${__BYTES_UNITS[$magnitude]}" == "$unit" ]]; then
            break
        fi
    done
    echo "$magnitude"
}

# @description Takes bytes and formats them into a human-readable format.
# Units table:
# | Symbol | Name      | ~Bytes (approx) |
# |--------|-----------|-----------------|
# | B      | Byte      | 1               |
# | KB     | Kilobyte  | 10^3            |
# | MB     | Megabyte  | 10^6            |
# | GB     | Gigabyte  | 10^9            |
# | TB     | Terabyte  | 10^12           |
# | PB     | Petabyte  | 10^15           |
# | EB     | Exabyte   | 10^18           |
fmt::bytes() {
    local bytes=$1
    local max_unit=${2:-EB}

    local -i magnitude
    magnitude=$(awk "BEGIN {print int(log($bytes) / log(1024))}")

    local unit=''
    if [[ -n "$max_unit" ]]; then
        local -i max_magnitude
        max_magnitude=$(fmt::__get_unit_magnitude "$max_unit")
        if [[ $magnitude -ge $max_magnitude ]]; then
            unit=$max_unit
        fi
    fi
    if [[ -z "$unit" ]]; then
        unit=${__BYTES_UNITS[$magnitude]}
    fi
    fmt::bytes_to "$bytes" "$unit"
}

# Function to convert bytes to a given unit
fmt::bytes_to() {
    local bytes=$1
    local unit=$2
    local conversion_factor
    local value

    conversion_factor=$(fmt::__get_unit_factor "$unit")
    value=$(awk "BEGIN {printf \"%.2f\", $bytes / $conversion_factor}")

    echo "$value $unit"
}
