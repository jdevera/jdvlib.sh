#!/usr/bin/env bash

: <<'jdvlib:doc'
Functions that relate to text manipulation.
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


# Take two arrays that represent columns and print them aligned
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

# @description Replace the content between two markers in a file.
# If the markers are not present, append to the file and add the markers.
# In any case keep the markers.
#
# @arg $1 string The file to edit
# @arg $2 string The start marker
# @arg $3 string The end marker
# @stdin The new content to replace between the markers
text::replace_between_markers_legacy() {
    ui::deprecate "text::replace_between_markers_legacy" "text::apply_in_place text::replace_inside_markers"
    local file=$1
    local start_marker=${2:-'#--SETUP-START--'}
    local end_marker=${3:-'#--SETUP-END--'}
    local new_content
    new_content=$(cat)

    if ! grep -q "$start_marker" "$file"; then
        {
            echo "$start_marker"
            echo "$new_content"
            echo "$end_marker"
        } >>"$file"
        return
    fi

    # Use awk to replace content between markers, ensuring the entire line matches the markers
    awk -v start="^$start_marker\$" -v end="^$end_marker\$" -v content="$new_content" '
    BEGIN {print_content=1}
    $0 ~ start {print $0; print content; print_content=0}
    $0 ~ end {print_content=1}
    print_content {print}
    ' "$file" >tmpfile && mv tmpfile "$file"
}

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

# Apply a filter to a file and write the result bak to the same file
# meant to be used with the filters in this module
text::apply_in_place() {

    local filter=$1
    local file=$2
    local tmpfile
    tmpfile=$(mktemp)

    $filter <"$file" >"$tmpfile" && mv "$tmpfile" "$file"
}

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

text::comment_out_inside_markers() {
    text::format_inside_markers "$1" "$2" "# %s"
}


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