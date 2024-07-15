#!/usr/bin/env bash

if ! code::is_sourced; then
    head -n 20 "$0" | sed -n '2,20p' | sed -e 's/^# //' -e 's/^#//'
fi
