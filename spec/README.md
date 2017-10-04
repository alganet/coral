Introduction
============

**coral** is a environment for developing software using the shell.

Programs written with coral will run almost anywhere:

 - **Linux**: Any distribution with bash, zsh, dash or busybox will do.
 - **OS X**: Any modern OS X with bash is supported.
 - **Windows**: Bash on Ubuntu, MinGW and Cygwin supported.
 - **Others**: If it can run a shell, coral will work.

Apart from a few essential command line utilities (such as cat and dirname),
coral requires **no dependencies** and run on bare installations of many
systems.

Modularity
----------

Code is encapsulated in modules, each module in its own file.

```sh file hello.sh

hello ()
{
	echo 'Hello'
}
```

Modules can reuse each other by declaring dependencies:

```sh file how_are.sh

require 'hello.sh'

how_are ()
{
	hello
	echo 'How are you?'
}
```

You can run the module with `coral`:

```console
$ ./coral how_are.sh
Hello
How are you?
```
