result-queue
====

this script is write command result to the queue file and load preferentially from it.

perhaps, be effective when select records at random from database.

the most slow processing of the selection is not the select from records. parse, sort, extract, etc... database tools has some processing before the selection.

therefore, get extra records as a technique. the processing of get extra records is faster than other some processing. but it has been garbage normally if unused.

this script's feature make more speedy by write the unused records it to the queue and read in next processing. used records are removed from the queue file after use.

## USAGE

you would be easy to understand if you read the `t/test-1.sh` and run it.

### run

```
./result-queue.sh -c "ls -l /" -l "3" -n 'tempfile'
```

run this example then echo 3 lines from the command result. the lines of extra are written to the queue file. if run in same `-n` option, echo from the queue file. if the command result is not enough lines then repeat `-c` command until to reach number of `-l`. the name of the queue file is 'tempfile' by `-n`.n`.

### opetions

#### -c

command for shell. run if the queue file is empty.

value of _STDOUT_ from the commands are handled as the result value by this script.

default value is none. but if exists _.command_ file for the queue file of task then use it. if neither has not been set, echo the error message and exit.

as wrote at the beginning, this was created to assist in the random selection from the database. perhaps, will be speedy if pass the command for get extra records in moderation.

#### -d

directory path for queue file.

default value is _._ . (working directory at run)

#### -i

initialize for command option.

write the `-c` option string to same directory of queue file. filename's suffix is _.command_. the `-c` option does not require when exists _.command_ file.

#### -l

number of lines for echo.  until reach the number of lines, read the queue file and repeat the commands.

default value is _1_ .

#### -n

the filename for queue file.

default value is _result-queue_ .

#### -s

the sleep frequency for command. when the number of repeat to command has reached it, run `sleep 1`.

default value is _50_ .

## AUTHOR

[indeep-xyz](http://indeep.xyz/)

