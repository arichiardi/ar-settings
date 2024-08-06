#!/bin/bash
# set -x

if [ ! ${#} -ge 3 ]; then
    echo 1>&2 "Usage: ${0} LOCAL REMOTE MERGED BASE"
    echo 1>&2 "       (LOCAL, REMOTE, MERGED, BASE can be provided by \`git mergetool'.)"
    exit 1
fi

_EMACSCLIENT=emacsclient-daemon.sh # using custom wrapper
_BASENAME=$(which basename)
_CP=$(which cp)
_EGREP=$(which egrep)
_MKTEMP=$(which mktemp)

# args coming from git
_LOCAL=${1}
_REMOTE=${2}
_MERGED=${3}

if [ -r ${4} ] ; then
    _BASE=${4}
    _EDIFF=ediff-merge-files-with-ancestor
    _EVAL="${_EDIFF} \"${_LOCAL}\" \"${_REMOTE}\" \"${_BASE}\" nil \"${_MERGED}\""
else
    _EDIFF=ediff-merge-files
    _EVAL="${_EDIFF} \"${_LOCAL}\" \"${_REMOTE}\" nil \"${_MERGED}\""
fi

${_EMACSCLIENT} -nw --eval "(${_EVAL})" 2>&1

# check modified file for unwanted conflict markers
# echo $_MERGED | xargs egrep '[><]{7}' -H -I --line-number
$(git --no-pager diff --check $_MERGED > /dev/null >&2)

if [ $? -ne 0 ]; then
    _MERGEDSAVE=$(${_MKTEMP} --tmpdir `${_BASENAME} ${_MERGED}`.XXXXXXXXXX)
    ${_CP} ${_MERGED} ${_MERGEDSAVE}
    echo 1>&2 "Oops! Conflict markers detected in $_MERGED."
    echo 1>&2 "Saved your changes to ${_MERGEDSAVE}"
    echo 1>&2 "Exiting with code 1."
    exit 1
else
    exit 0
fi
