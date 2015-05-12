#!/bin/bash
# Opens a two tabbed windows, one with full logs (Verbose if not specified as second parameter on the command line) and one with just error logs.

LEVEL=V
if [ -n "$2" ]; then
  echo "Setting level: $2"
  LEVEL=$2
fi

echo "Launching pidcat.py with package $1, level $LEVEL"
xfce4-terminal --window --title="Logcat Level: $LEVEL" -H --command="bash -i -c '~/bin/pidcat.py --always-display-tags --min-level=$LEVEL $1'" --tab --title 'Logcat Level: E' --command="bash -i -c '~/bin/pidcat.py --always-display-tags --min-level=E $1'"
