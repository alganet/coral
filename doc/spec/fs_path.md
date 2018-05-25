fs_path
=======

Finds files in a list of paths. Useful for when you want to look for
executables without changing the $PATH and a replacement for `which`
in many cases.

Sample Usage
------------

Simplest usage emulates the built-in `$PATH` lookup:

```console task
$ ./lib/dev fs_path sh
/bin/sh
$ ./lib/dev fs_path cp
/bin/cp
```

You can also provide your own path for lookup, using `:` as path
separator:

```console task
$ ./lib/dev fs_path sh '/bin:/usr/bin'
/bin/sh
```

Specification
-------------

First, let's create some folders and files to test our paths:

```console test
$ mkdir some_dir
$ printf 'Some content...' > ./some_dir/SOME_FILE.txt
```

Using the current folder as path should work, in case you want to use
a variable and leave '.' as a default.

```console test
$ printf '' > ./SOME_FILE.txt
$ ./lib/dev fs_path SOME_FILE.txt .
./SOME_FILE.txt
```

We can then use the fs_path function to look for files there:

```console test
$ ./lib/dev fs_path SOME_FILE.txt "./some_dir"
./some_dir/SOME_FILE.txt
```
