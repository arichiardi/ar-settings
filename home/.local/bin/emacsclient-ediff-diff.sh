#!/bin/bash
# set -x

# test args
if [ ! ${#} -ge 2 ]; then
    echo 1>&2 "Usage: ${0} FILE1 FILE2"
    exit 1
fi

# tools
_EMACSCLIENT=$(which emacsclient)
_BASENAME=$(which basename)

_FILE1=${1}
_FILE2=${2}

emacsclient-daemon.sh -nw --eval "(ediff-merge-files \"${_FILE1}\" \"${_FILE2}\")"
