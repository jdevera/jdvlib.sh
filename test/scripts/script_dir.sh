#!/usr/bin/env bash

# shellcheck source=./../../lib/code.sh
source "$PROJECT_ROOT/lib/code.sh"

function directly_on_script() {
    # shellcheck disable=SC2119 # I really don't want to call with parameters
    code::script_dir
}

function called_in_sourced_file() {
    local extra_level=${1:-0}
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT
    cat <<EOF > "$tmp_dir/sourced_file.sh"
#!/usr/bin/env bash
source "$PROJECT_ROOT/lib/code.sh"

__generated_test_function() {
    code::script_dir $extra_level
}
EOF
    # shellcheck disable=SC1090
    source "$tmp_dir/sourced_file.sh"
    __generated_test_function

}

location=$1
shift
case $location in
    script)
        directly_on_script
        ;;
    sourced-file)
        called_in_sourced_file "${1:-0}"
        ;;
    *)
        echo "Unknown location: $location" >&2
        exit 1
        ;;
esac
