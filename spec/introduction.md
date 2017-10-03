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
