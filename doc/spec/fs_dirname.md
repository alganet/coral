fs_dirname
==========

Extracts the directory name portion of a path and prints it out.

            dirname           filename
               |                 |
       __________________   ____________
     /some/example/path/to/this_is_a_file

Sample Usage
------------

Extracting the directory name `foo` from the `foo/bar` path:

```console test
$ ./lib/dev fs_dirname foo/bar
foo
```

Dealing with file names:

```console test
$ ./lib/dev fs_dirname foo/bar/baz
foo/bar
$ ./lib/dev fs_dirname foo/bar/baz.lorem
foo/bar
$ ./lib/dev fs_dirname foo/bar/.ipsum
foo/bar
```

Dealing with multiple and absolute slashes:

```console test
$ ./lib/dev fs_dirname foo/bar//.ipsum
foo/bar
$ ./lib/dev fs_dirname foo/bar/////.ipsum
foo/bar
$ ./lib/dev fs_dirname /some/example/path/to/this_is_a_file
/some/example/path/to
```
