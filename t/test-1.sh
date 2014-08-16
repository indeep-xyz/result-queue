#!/bin/bash

MY_DIR="`readlink -f "$0" | sed 's!/[^/]*$!!'`"
BIN="$MY_DIR/../result-queue.sh"

DIR="/tmp/result-queue-1/"
NAME="test-1"
GET_LINES=4

CMD="`cat <<EOT
ls -l
echo test-test-test-test
EOT`"

$BIN -i -c "$CMD" -d "$DIR" -n "$NAME" -l "$GET_LINES"
