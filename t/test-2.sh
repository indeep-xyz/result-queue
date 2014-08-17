#!/bin/bash
#
# test
# command result is empty (-e)

MY_DIR="`readlink -f "$0" | sed 's!/[^/]*$!!'`"
BIN="$MY_DIR/../result-queue.sh"

DIR="/tmp/result-queue-t/"
NAME="test-2"
GET_LINES=4
EMPTY_LIMIT=5

CMD="`cat <<EOT
echo ''
EOT`"

# - - - - - - - - - - - - - - - - - -
# main

mkdir -p $DIR

# run test
$BIN -c "$CMD" -d "$DIR" -n "$NAME" -l "$GET_LINES" -e $EMPTY_LIMIT

