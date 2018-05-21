Building `coral` from scratch
=============================

The `coral` repository does not contain a built version of any library.

In order to work with the modules [pre-assembling](module_assemble.md),
we need to load them in a bootstrap environment.

Introduction
------------

To make this easy, we provide the `./lib/dev` module. You can use it
to load any other module from the `coral/lib` repository:

```console test
$ ./lib/dev fs_basename hello/world
world
```

It will also look for modules in whatever the current folder you are in,
allowing quick prototyping:

```sh file example.sh
# example.sh

example ()
{
    echo hello
}
```

```console test
$ ./lib/dev example
hello
```

Building the Builder
--------------------

Let's first build the `module_assemble` module itself. We can then use
it to assemble anything we want and run it independently from `./lib/dev`:

```console test
$ ./lib/dev module_assemble module_assemble module_assemble
$ test -e module_assemble && echo Exists
Exists
```
