#!/bin/bash
#
# Emacs dired from a given dir.
#

set -euo pipefail

dired_dir=${1:-$(pwd)}

emacsclient-daemon.sh -nw --eval '(dired '\""$dired_dir"\"')'
