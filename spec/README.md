Post-Modern Shell Scripting
===========================

The UNIX Shell has been an important piece of software tooling and
infrastructure for decades.

It has evolved and spawn a series of robust technologies. From busybox to zsh,
the UNIX-like shell is widely available and supported.

What Is The Shell?
------------------

It is a program that reads text and execute commands.

You can either use it interactively through a console:

```console
$ name=World
$ echo "Hello $name"
Hello World
```

Or write a script to execute a series of commands:

```sh file example.sh
printf 'How '
printf 'are '
printf 'you?'
```

Scripts can be run and reused individually:

```console
$ chmod +x example.sh
$ ./example.sh
How are you?
```
