#!/usr/bin/env bash

set -e
set -u
set -o pipefail

__JDVLIB_PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
__JDVLIB_DIR=$__JDVLIB_PROJECT_DIR/lib
__JDVLIB_VERSION="0.0.0"

# shellcheck source=./lib/_meta.sh
source "$__JDVLIB_DIR/_meta.sh"
# shellcheck source=./lib/ui.sh
meta::import ui
# shellcheck source=./lib/text.sh
meta::import text
# shellcheck source=./lib/fs.sh
meta::import fs
# shellcheck source=./lib/args.sh
meta::import args
# shellcheck source=./lib/env.sh
meta::import env
# shellcheck source=./lib/func.sh
meta::import func


DEST=
DEST_FULL_PATH=
target_compiler=

usage() {
    cat <<EOF
Usage: $0 [options] target [dest]
EOF
}

help() {
    cat <<EOF
Compile the library, ot its docs.

$(usage)

ARGUMENTS:
    target    What to build. Options: lib, doc, readme
    dest      The destination file. Default: '-' (stdout)

TARGETS:
    lib       Compile the full library to a single file
    doc       Compile the documentation
    readme    Compile the variable parts of the README file
              A file destination will be ignored

OPTIONS:
    -h, --help    Show this help message and exit
EOF
}

set_version() {
    local git_version
    declare -g __JDVLIB_VERSION
    git_version=$(git describe --tags --long | awk -F'-' '{print $1"-"$2}')
    __JDVLIB_VERSION=$git_version
}

# Print to the destination file or stdout
out() {
    env::ensure_is_set DEST_FULL_PATH
    if [[ "$DEST_FULL_PATH" == "-" ]]; then
        cat "$@"
    else
        cat "$@" >>"$DEST_FULL_PATH"
    fi
}

if_dest_is_file() {
    if [[ $DEST != "-" ]]; then
        "$@"
    fi
}

comment_out_imports() {
    text::comment_out_inside_markers \
        "# jdvlib: --- BEGIN IMPORTS ---" \
        "# jdvlib: --- END IMPORTS ---"
}

init_dest_file() {
    local mode="${1:-'--append'}"
    declare -g DEST_FULL_PATH
    if [[ $DEST != "-" ]]; then
        case $mode in
        --truncate)
            echo -n >"$DEST" || ui::die "Could not write to file: $DEST"
            ;;
        --append)
            touch "$DEST" || ui::die "Could not write to file: $DEST"
            ;;
        *)
            ui::die "Unknown file mode: $mode"
            ;;
        esac
        DEST_FULL_PATH=$(realpath "$DEST")
    else
        DEST_FULL_PATH=-
    fi
}

handle_args() {
    declare -g TARGET DEST target_compiler
    # Check for help:
    args::check_help_arg help "$@"

    args::ensure_num_args_between 1 2 usage "$@"

    TARGET=$1
    DEST=${2:-''}


    case $TARGET in
    lib)
        target_compiler=target_lib
        ;;
    doc)
        target_compiler=target_doc
        ;;
    readme)
        target_compiler=target_readme
        ;;
    *)
        ui::die "Error: Unknown target: $TARGET"
        ;;
    esac
}

# Override source to output the file contents
source_override_attach_code() {
    if_dest_is_file ui::echo_step "Attaching file: $1"
    {
        echo -e "\n## --- Begin File: $1 --- [[["
        cat "$@" | comment_out_imports
        echo -e "\n## --- End File: $1 --- ]]]"
    } | out
}

library_metadata() {
    local major minor patch commits
    echo "# Version: ${__JDVLIB_VERSION}"
    echo "#"

    echo "__JDVLIB_VERSION='${__JDVLIB_VERSION}'"
    # Version has the format major.minor.patch-commits
    IFS=. read -r major minor patch commits <<<"${__JDVLIB_VERSION/-/.}"

    echo "__JDVLIB_VERSION_PARTS=( $major $minor $patch $commits)"
    echo "__JDVLIB_GIT_HASH='$(git rev-parse HEAD)'"
    echo "__JDVLIB_BUILD_DATE='$(date -u +'%Y-%m-%d')'"
}

target_lib() {
    set_version
    local header_file=./templates/header.sh
    local footer_file=./templates/footer.sh
    DEST=${DEST:-'-'}
    fs::ensure_file_exists "$header_file"
    fs::ensure_file_exists "$footer_file"
    source() {
        source_override_attach_code "$@"
    }
    init_dest_file --truncate
    out "$header_file"
    library_metadata | out


    # Since "source" is overridden, calling it with builtin to make sure this is the real one
    command source ./lib/lib.sh
    out "$footer_file"
}

get_module_doc() {
    local with_functions
    local -a args
    args::get_flag_value --functions with_functions args "$@"
    set -- "${args[@]}"

    local file=$1
    local module_name
    module_name=$(basename -s .sh "$file")
    echo "### Module \`$module_name\`"
    echo
    text::read_inside_markers \
        ": <<'jdvlib:doc'" \
        "jdvlib:doc" \
        "$file"
    echo
    if [[ $with_functions == 'true' ]]; then
        echo "#### Functions"
        echo
        local functions count
        # shellcheck disable=SC2016 # We want the backticks to be literal
        functions=$(func::list_functions_in_file "$file" | sed 's/\(.*\)/- `\1`/')
        count=$(echo "$functions" | wc -l | awk '{print $1}')
        if [[ $count -gt 25 ]]; then
            echo '<details>'
            echo "<summary>Click to expand ($count functions)</summary>"
            echo
            echo "$functions"
            echo
            echo '</details>'
        else
            echo "$functions"
        fi
        echo
    fi
}

source_override_document_modules() {
    if_dest_is_file ui::echo_step "Documenting file: $1"
    get_module_doc "$1" | out
}

target_doc() {
    DEST=${DEST:-'-'}
    source() {
        source_override_document_modules "$@"
    }
    init_dest_file --truncate

    # Since "source" is overridden, calling it with builtin to make sure this is the real one
    command source ./lib/lib.sh
}

source_override_readme() {
    if_dest_is_file ui::echo_step "Documenting file: $1" >&2
    get_module_doc --functions "$1"
}

target_readme() {
    local README_FILE="$__JDVLIB_PROJECT_DIR/README.md"
    source() {
        source_override_readme "$@"
    }

    # No argument means we are writing to the README file
    if [[ $DEST != "-" ]]; then
        if [[ -n $DEST ]]; then
            ui::warn "Destination file will be ignored for target: $TARGET"
        fi
        DEST=$README_FILE
    fi
    init_dest_file --append

    local docs
    # Since "source" is overridden, calling it with builtin to make sure this is the real one
    docs="$(command source ./lib/lib.sh)"

    filter_function() {
        text::replace_inside_markers \
            '<!-- MODULES:START -->' \
            '<!-- MODULES:END -->' \
            "$docs"
    }

    if [[ $DEST == "-" ]]; then
        filter_function < "$__JDVLIB_PROJECT_DIR/README.md"
    else
        text::apply_in_place filter_function "$__JDVLIB_PROJECT_DIR/README.md"
    fi
}


handle_args "$@"

fs::ensure_file_exists ./lib/lib.sh

if_dest_is_file ui::info "Building target: $TARGET"

# This will let the files know that they are being sourced for compilation
# Some places may need to know this to avoid running code that is not needed
# bashsupport disable=BP2001 # No, variable could definitely not be declared local
export __jdvlib_compiling=true

"$target_compiler"

if_dest_is_file ui::ok "$TARGET compiled on $DEST"
