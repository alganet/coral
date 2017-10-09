entrypoint Module
=================

The entrypoint is a simple shell script that runs the command stored
in the `entrypoint` variable passing along all arguments.

Here's a sample using `echo` as an entrypoint:

```console
$ entrypoint=echo ${SHELL} ./lib/require/entrypoint Hello World
Hello World
```

If no entrypoint is provided, it does nothing:

```console
$ entrypoint='' ${SHELL} ./lib/require/entrypoint Hello
```
