result-queue
====

this script is write command result to the queue file and load preferentially from it.

perhaps, be effective when select records at random from database.

## USAGE

you would be easy to understand if you read the `t/test-1.sh` and run it.

### run

```
./result-queue.sh -c "ls -l /" -l "3" -n 'tempfile'
```

run this example then echo 3 lines from the command result. the lines of extra are written to the queue file.

if run in same `-n` option, echo from the queue file. name of the queue file is 'tempfile'  by `-n`.

### opetions

#### -c

command for shell. run if the queue file is empty.

value of _STDOUT_ from the commands are handled as the result value by this script.

default value is none. but if exists _.command_ file for the queue file of task then use it. if neither has not been set, echo the error message and exit.

as wrote at the beginning, this was created to assist in the random selection from the database. perhaps, will be speedy if pass the command for get extra records in moderation.

#### -d

directory path for queue file.

default value is _._ . (working directory at run)

#### -e

number of limit for the empty result.

default value is _5_ .

#### -i

initialize for command option.

write the `-c` option string to same directory of queue file. filename's suffix is _.command_. the `-c` option does not require when exists _.command_ file.

recommend to set with `-r` option. `-i` option does not support to reset the queue file.

#### -l

number of lines for echo.  until reach the number of lines, read the queue file and repeat the commands.

default value is _1_ .

#### -n

the filename for queue file.

default value is _result-queue_ .

#### -r

reset queue file.

#### -s

the sleep frequency for command. when the number of repeat to command has reached it, run `sleep 1`.

default value is _50_ .

## AUTHOR

[indeep-xyz](http://indeep.xyz/)
