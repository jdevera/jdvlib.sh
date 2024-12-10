# shellcheck shell=bash

if ! code::is_sourced; then
    case "$1" in
        --version | -v)
            echo "$__JDVLIB_VERSION"
            exit 0
            ;;
        *)
            head -n 20 "$0" | sed -n '2,20p' | sed -e 's/^# //' -e 's/^#//'
            exit 0
            ;;
    esac
fi
