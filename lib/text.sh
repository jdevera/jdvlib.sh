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

# @section text
# @description Functions that relate to text manipulation.

# @description Print two arrays as left-aligned columns.
#   The left column width is determined by the longest entry.
#
# @arg $1 array The left column array (nameref).
# @arg $2 array The right column array (nameref).
#
# @stdout The aligned two-column output.
text::print_aligned() {
    local -n left=$1
    local -n right=$2
    local left_width=0
    local i
    for i in "${left[@]}"; do
        if [[ ${#i} -gt $left_width ]]; then
            left_width=${#i}
        fi
    done
    for i in "${!left[@]}"; do
        printf "%-${left_width}b %b\n" "${left[$i]}" "${right[$i]}"
    done
}

# @description Replace the content between two markers in a text stream.
#   If the markers are not present, append the markers and new content.
#   The markers themselves are preserved.
#
# @arg $1 string The start marker.
# @arg $2 string The end marker.
# @arg $3 string The new content to place between the markers.
# @arg $@ string Optional input files (reads from stdin if none).
#
# @stdout The modified text.
text::replace_inside_markers() {
    local start_marker=$1
    local end_marker=$2
    local new_content=$3
    shift 3

    new_content=$(echo -e "$new_content")

    # Use awk to replace content between markers, ensuring the entire line matches the markers
    # Pass the new content through the environment because awk can't handle newlines in arguments
    content=$new_content awk -v start="$start_marker" -v end="$end_marker" '
    function printContent() {
        n = split(ENVIRON["content"], lines, "\n")
        for (i = 1; i <= n; i++) {
            print lines[i]
        }
    }
    BEGIN {
        replacement_done=0
        output_enabled=1
        start_pattern = "^" start "$"
        end_pattern = "^" end "$"
    }
    $0 ~ start_pattern {
        print $0
        printContent()
        output_enabled=0
        replacement_done=1
    }
    $0 ~ end_pattern {
        output_enabled=1
    }
    output_enabled { print }
    END {
        if (!replacement_done) {
            print start
            printContent()
            print end
        }
    }
    ' "$@"

}

# @description Delete content between two markers, keeping the markers.
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
# @arg $@ string Optional input files (reads from stdin if none).
#
# @stdout The text with content between markers removed.
#
# @exitcode 0 If the start marker was found.
# @exitcode 1 If the start marker was not found.
text::delete_inside_markers() {
    local start_delim="$1"
    local end_delim="$2"
    shift 2

    awk -v start="^$start_delim\$" -v end="^$end_delim\$" '
    BEGIN { start_found = 0 }
    $0 ~ start, $0 ~ end {   # if we are between the start and end markers
        start_found = 1      # Remember that we found the start marker
        if ($0 ~ start || $0 ~ end) print  # print the start and end markers
        next                 # skip the rest of the lines
    }
    { print }                # print all other lines outside the markers
    END { exit !start_found } # exit with 0 if we found the start marker
    ' "$@" && return 0 || return 1
}


# @description Delete the markers and all content between them.
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
# @arg $@ string Optional input files (reads from stdin if none).
#
# @stdout The text with the marker block entirely removed.
#
# @exitcode 0 If the start marker was found.
# @exitcode 1 If the start marker was not found.
text::delete_around_markers() {
    local start_delim="$1"
    local end_delim="$2"
    shift 2

    awk -v start="^$start_delim\$" -v end="^$end_delim\$" '
    BEGIN { start_found = 0 }
    $0 ~ start, $0 ~ end {   # if we are between the start and end markers
        start_found = 1      # Remember that we found the start marker
        next                 # skip the rest of the lines
    }
    { print }                # print all other lines outside the markers
    END { exit !start_found } # exit with 0 if we found the start marker
    ' "$@" && return 0 || return 1
}

# @description Apply a filter command to a file in place.
#   The filter reads from stdin and writes to stdout. The result
#   replaces the original file content.
#
# @arg $1 string The filter command to apply.
# @arg $2 string The file to modify in place.
text::apply_in_place() {

    local filter=$1
    local file=$2
    local tmpfile
    tmpfile=$(mktemp)

    $filter <"$file" >"$tmpfile" && mv "$tmpfile" "$file"
}

# @description Read and print only the content between two markers.
#   The markers themselves are excluded from the output.
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
# @arg $@ string Optional input files (reads from stdin if none).
#
# @stdout The content between the markers.
text::read_inside_markers() {
    local start_delim="$1"
    local end_delim="$2"
    shift 2

    awk -v start="^$start_delim\$" -v end="^$end_delim\$" '
    $0 ~ start, $0 ~ end {
        if ($0 !~ start && $0 !~ end) print
    }
    ' "$@"
}

# @description Apply a printf format string to each line between two markers.
#   Lines outside the markers and the markers themselves are printed as-is.
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
# @arg $3 string The printf format string to apply to each line.
# @arg $@ string Optional input files (reads from stdin if none).
#
# @stdout The text with formatted content between markers.
text::format_inside_markers() {
    local start_delim=$1
    local end_delim=$2
    local format_str=$3
    shift 3

    awk \
        -v start="$start_delim" \
        -v end="$end_delim" \
        -v format="$format_str" \
        '
    $0 ~ start, $0 ~ end {
        if ($0 !~ start && $0 !~ end)
            printf(format "\n", $0)
        else
            print
        next
    }
    { print }
    ' "$@"
}

# @description Comment out all lines between two markers by prefixing them with "# ".
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
#
# @see text::format_inside_markers()
text::comment_out_inside_markers() {
    text::format_inside_markers "$1" "$2" "# %s"
}


# @description Apply a shell filter to lines between two markers.
#   Each line between the markers is piped through the filter command.
#   Lines outside the markers are printed as-is.
#
# @arg $1 string The start delimiter.
# @arg $2 string The end delimiter.
# @arg $3 string The filter command to apply to each line.
# @arg $4 string Optional input file (reads from stdin if empty).
#
# @stdout The text with filtered content between markers.
text::filter_inside_markers() {
    local start_delim=$1
    local end_delim=$2
    local filter=$3
    local input_file=${4:-}
    shift 3

    cat_maybe() {
        if [[ -n $1 ]]; then
            cat "$1"
        else
            cat
        fi
    }

    local inside_block=0
    local line
    while read -r line; do
        if [[ $line =~ $start_delim ]]; then
            inside_block=1
            echo "$line"
            continue
        fi
        if [[ $line =~ $end_delim ]]; then
            inside_block=0
            echo "$line"
            continue
        fi
        if [[ $inside_block -eq 1 ]]; then
            echo "$line" | $filter
        else
            echo "$line"
        fi
    done < <(cat_maybe "$input_file")
}
