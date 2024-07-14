#!/usr/bin/env bash

# shellcheck source=./../../lib/ansi.sh
source "$PROJECT_ROOT/lib/ansi.sh"

# shellcheck source=./../../lib/ui.sh
source "$PROJECT_ROOT/lib/ui.sh"


old_function() {
    ui::deprecate "old_function" "new_function"
    echo "still work"
}

# This is the calling site of the deprecated function:
# It should be line: 17
old_function