#!/bin/bash

MY_NAME=result-queue
MY_VERSION=0.1

# - - - - - - - - - - - - - - - - - - - - -
# command options
# {{{1

while getopts ic:d:n:l:s:h? OPT
do
  case $OPT in
    i)    FLG_INIT=1;;
    c)    CMD="$OPTARG";;
    d)    DIR="`echo "$OPTARG" | sed 's!/*$!!'`";;
    n)    NAME="$OPTARG";;
    l)    ECHO_LIMIT_TEMP=$OPTARG;;
    s)    SLEEP_FREQ_TEMP=$OPTARG;;
    h|\?)
      cat <<EOT
$MY_NAME $MY_VERSION

EOT
      exit 0
      ;;
  esac
done

shift $((OPTIND - 1))

# }}}1 command options

# - - - - - - - - - - - - - - - - - - - - -
# initialize variables
# {{{1

# = defaults for the command option

: ${FLG_INIT:=0}
: ${DIR:='.'}
: ${NAME:='result-queue'}
: ${ECHO_LIMIT:=1}

declare -i ECHO_LIMIT=$ECHO_LIMIT_TEMP
declare -i SLEEP_FREQ=$SLEEP_FREQ_TEMP

[ $ECHO_LIMIT -lt 1 ] && ECHO_LIMIT=1
[ $SLEEP_FREQ -lt 1 ] && SLEEP_FREQ=50

# = other basics

PATH_QUEUE="$DIR/$NAME"
PATH_COMMAND="${PATH_QUEUE}.command"

declare -i ECHO_COUNT=0

# = $CMD

# check $CMD and $FLG_INIT
if [ -n "$CMD" ] && [ "$FLG_INIT" = "1" ]; then

  # if exists $CMD and $FLG_INIT is 1
  # - initialize command file
  echo -e "$CMD" > "$PATH_COMMAND"
fi

# check $CMD and command file
if [ -z "$CMD" ] \
    && [ -f "$PATH_COMMAND" ]; then

  # if $CMD empty and exixts loadable command file
  # - set variable
  CMD="`cat "$PATH_COMMAND"`"
fi

echo -e "echo limit = $ECHO_LIMIT"
echo -e "echo count = $ECHO_COUNT"

# }}}1 initialize variables

# - - - - - - - - - - - - - - - - - - - - -
# functions
# {{{1

load_queue() {

  if [ -f "$PATH_QUEUE" ]; then
    process_queue "`cat "$PATH_QUEUE"`"
  fi
}

# = =
# save to queue file
#
# args
# $1 ... text
save_queue() { # {{{5

  local p="$PATH_QUEUE"
  local p_temp="${p}.~temp"

  # check text for update
  if [ -n "$1" ]; then

    # if exists text
    # - update
    echo -e "$1" > "$p_temp"
    mv "$p_temp" "$p"

  elif [ -f "$p" ]; then

    # if not exists text and exists queue file
    # - remove
    rm "$p"
  fi
} # }}}5

# = =
# process by queue text
#
# args
# $1 ... queue text
process_queue() { # {{{5

  local queue="$1"
  local extra=
  local IFS=$'\n'

  for line in `echo -e "$queue"`
  do
    if [ $ECHO_COUNT -lt $ECHO_LIMIT ]; then
      echo $line
      let ECHO_COUNT+=1
    else
      extra="${extra}${line}\n"
    fi
  done

  # update queue
  save_queue "$extra"
} # }}}5

run_command() {

  local -i cnt=0

  while :
  do

    # check the number of result lines
    if [ $ECHO_COUNT -ge $ECHO_LIMIT ]; then

      # if enough number of lines
      # - break loop
      break
    fi

    # run command
    process_queue "$(eval "`echo -e "$CMD"`")"

    let cnt++
    if [ $cnt -ge $SLEEP_FREQ ]; then

      sleep 1
      let cnt=0
    fi
  done
}


# - - - - - - - - - - - - - - - - - - - - -
# other

# = =
# echo error message
#
# args
# $1 ... message
echo_error() { # {{{5

  echo -e "\e[31m<<error by $MY_NAME\e[m"
  echo -e "$1"
} # }}}5

# }}}1 functions

# - - - - - - - - - - - - - - - - - - - - -
# guard
# {{{1

# require $CMD
if [ -z "$CMD" ]; then

  echo_error "`cat <<EOT

require command data
  - $MY_NAME -c "command"
  - write to '$PATH_COMMAND'
EOT`"
  exit 1
fi

# }}}1 guard

# - - - - - - - - - - - - - - - - - - - - -
# main
# {{{1

# load from queue
load_queue
run_command

# }}}1 main
