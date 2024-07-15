#!/usr/bin/env bash

module=$1
if [[ -n $module ]]; then
    exec ./test/bats/bin/bats "test/$module.bats"
    exit
else
    bash ./test/bats/bin/bats test
fi
