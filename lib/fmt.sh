#!/usr/bin/env bash


# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_meta.sh"

meta::import ui
meta::import sys

# jdvlib: --- END IMPORTS ---

# @section fmt
# @description Functions to format data.

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

# @description Format a byte count into a human-readable string.
#   Automatically selects the most appropriate unit (B, KB, MB, GB, TB, PB, EB).
#   An optional maximum unit can be specified to cap the conversion.
#
# @arg $1 number The number of bytes.
# @arg $2 string Optional maximum unit to use (default: EB).
#
# @stdout The formatted value with unit (e.g. "1.50 GB").
#
# @example
#   fmt::bytes 1536       # prints "1.50 KB"
#   fmt::bytes 1073741824 # prints "1.00 GB"
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

# @description Convert a byte count to a specific unit.
#
# @arg $1 number The number of bytes.
# @arg $2 string The target unit (B, KB, MB, GB, TB, PB, or EB).
#
# @stdout The converted value with unit (e.g. "2.50 MB").
fmt::bytes_to() {
    local bytes=$1
    local unit=$2
    local conversion_factor
    local value

    conversion_factor=$(fmt::__get_unit_factor "$unit")
    value=$(awk "BEGIN {printf \"%.2f\", $bytes / $conversion_factor}")

    echo "$value $unit"
}
