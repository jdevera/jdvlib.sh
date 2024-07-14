#!/usr/bin/env bash

__JDVLIB_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


pushd "$__JDVLIB_PATH" &> /dev/null || exit 1

source ansi.sh
source args.sh
source code.sh
source compat.sh
source env.sh
source fs.sh
source func.sh
source pve.sh
source sys.sh
source text.sh
source ui.sh
source user.sh

popd &> /dev/null || exit 1