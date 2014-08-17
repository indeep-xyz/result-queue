#!/bin/bash
#
# test
# reset option (-r)

MY_DIR="`readlink -f "$0" | sed 's!/[^/]*$!!'`"
BIN="$MY_DIR/../result-queue.sh"

DIR="/tmp/result-queue-t/"
NAME="test-3"
GET_LINES=1

CMD="`cat <<EOT
ls /
EOT`"

# - - - - - - - - - - - - - - - - - -
# main

mkdir -p $DIR

# run test
$BIN -c "$CMD" -d "$DIR" -n "$NAME" -l "$GET_LINES" -r

# check the queue file after run.
#
# result is always the same string so queue file is re-created every.
# can't reach to second line in queue file.
