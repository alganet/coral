script_entrypoint
=================

The entrypoint is a simple shell script that runs the command stored
in the `entrypoint` variable passing along all arguments.

Here's a sample using `echo` as an entrypoint:

```console test
$ entrypoint=echo ${SHELL} ./lib/script/entrypoint Hello World
Hello World
```

If no entrypoint is provided, it does nothing:

```console test
$ entrypoint='' ${SHELL} ./lib/script/entrypoint Hello
```
