Post-Modern Shell Scripting
===========================

The UNIX Shell has been an important piece of software tooling and
infrastructure for decades.

It has evolved and spawn a series of robust technologies. From busybox to zsh,
the UNIX-like shell is widely available and supported.

What Is The Shell?
------------------

It is a program that reads text and execute commands. You can either use it
interactively through a console:

```console
$ echo "Hello World"
Hello World
```

Or write a script to execute a series of commands:

```sh file hello.sh
#!/usr/bin/env sh

printf '%s, ' "${1:-Hey}"
echo
printf 'How '
printf 'are '
printf 'you?'
```

Scripts can be run and reused individually:

```console
$ chmod +x hello.sh
$ ./hello.sh
Hey, 
How are you?
$ ./hello.sh Alexandre
Alexandre, 
How are you?
```

What Can It Do?
---------------

The core Shell features are:

- File manipulation
```console
$ # Directing input to a file
$ echo 'Hello World       ' > hello.txt
$ # Displaying file contents
$ cat hello.txt
Hello World       
```

- Piping and interaction with other commands
```console
$ # Seeing non-printable characters
$ cat hello.txt | sed s/Hello/Hey/
Hey World       
$ # Counting chars
$ echo $(cat hello.txt | wc -c)
19
```

- Text manipulation
```console
$ # Making text uppercase
$ cat hello.txt | tr '[a-z]' '[A-Z]'
HELLO WORLD       
```

These and many other possibilities are available in any UNIX-like shell
environment. 

The Shell Language
------------------

Several control structures are available to develop powerful scripts.

### Return Codes

Every command and function execution on the shell have a return code. A `0`
return code means success.

You can access the return code of the last command executed using the variable `$?`:

```console
$ echo 'This always works'
This always works
$ echo $?
0
```

The `true` and `false` commands always return `0` and `1` respectively:

```console
$ true
$ echo $?
0
$ false
$ echo $?
1
```


### The `test` command

Often a built-in (embedded in the shell), sometimes available as a standalone
command, `test` can perform operator comparisons:

```console
$ test 1 = 0 # equals
$ echo $?
1
$ test 1 -gt 0 # greater than
$ echo $?
0
$ test 1 -lt 0 # lesser than
$ echo $?
1
$ test -z "" # is empty
$ echo $?
0
$ test ! -z "" # the not operator
$ echo $?
1
$ test -n "a" # not empty
$ echo $?
0
```

It can also deal with files. Let's setup some filesystem examples:

```console
$ mkdir mydir
$ touch mydir/myfile
$ echo "#!/usr/bin/env sh" > mydir/myfile
$ chmod +x mydir/myfile
$ touch mydir/otherfile
$ test -d "mydir" # is directory
$ echo $?
0
$ test -f "mydir/myfile" # is file
$ echo $?
0
$ test -x "mydir/myfile" # is executable
$ echo $?
0
$ test -r "mydir/myfile" # is readable
$ echo $?
0
$ test -w "mydir/myfile" # is writeable
$ echo $?
0
```
