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
_CP=$(which cp)
_EGREP=$(which egrep)
_MKTEMP=$(which mktemp)

# args
_FILE1=${1}
_FILE2=${2}

_EDIFF=ediff-merge-files
_EVAL="${_EDIFF} \"${_FILE1}\" \"${_FILE2}\""

# console vs. X
if [ "${TERM}" = "linux" ]; then
    unset DISPLAY
    _EMACSCLIENTOPTS="-t"
else
    _EMACSCLIENTOPTS="-c"
fi

# run emacsclient
${_EMACSCLIENT} ${_EMACSCLIENTOPTS} -a "" -e "(${_EVAL})" 2>&1
