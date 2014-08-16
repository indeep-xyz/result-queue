#!/bin/bash

MY_NAME=result-queue
MY_VERSION=1.0

# - - - - - - - - - - - - - - - - - - - - -
# command options
# {{{1

while getopts c:d:l:n:s:hi? OPT
do
  case $OPT in
    c)    CMD="$OPTARG";;
    d)    DIR="`echo "$OPTARG" | sed 's!/*$!!'`";;
    i)    FLG_INIT=1;;
    l)    ECHO_LIMIT_TEMP=$OPTARG;;
    n)    NAME="$OPTARG";;
    s)    SLEEP_FREQ_TEMP=$OPTARG;;
    h|\?)
      cat <<EOT
$MY_NAME $MY_VERSION

this script is write command result to the queue file and load preferentially from it.

created to assist for random selection from the database.
perhaps, will be speedy if pass the command for get extra records in moderation.

[usage]
  $MY_NAME [option]

[option]
  -c command for shell.
     value of _STDOUT_ from the commands are handled as the result value by this script.

  -d directory path for queue file.

  -i initialize for command option.

     write the -c option string to same directory of queue file.
     filename's suffix is .command. the -c option does not require when exists .command file.

  -l number of lines for echo.
     until reach the number of lines, read the queue file and repeat the commands.

  -n filename for queue file

  -s the sleep frequency for command.
     when the number of repeat to command has reached it, run sleep 1.
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

# echo from queue
load_queue

# echo from command
run_command

# }}}1 main
