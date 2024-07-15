#!/usr/bin/env bash

# shellcheck source=./../../lib/code.sh
source "$PROJECT_ROOT/lib/code.sh"

if code::is_sourced; then
    echo "sourced"
else
    echo "ran"
fi
