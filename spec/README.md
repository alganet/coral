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
printf 'how '
printf 'are '
printf 'you?'
```

Scripts can be run and reused individually:

```console
$ chmod +x hello.sh
$ ./hello.sh
Hey, how are you?
$ ./hello.sh Alexandre
Alexandre, how are you?
```

What Can It Do?
---------------

The core Shell features are:

- File manipulation
```console
ldknf
```
- Text manipulation
- Interaction with other commands

