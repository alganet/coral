fs_dirname
==========

Extracts the directory name portion of a path.

            dirname           filename    
               |                 |
       __________________   ____________
     /some/example/path/to/this_is_a_file

Let's try some examples:

```console test 
$ ./lib/dev fs_dirname foo/bar
foo
$ ./lib/dev fs_dirname foo/bar/baz
foo/bar
$ ./lib/dev fs_dirname foo/bar/baz.lorem
foo/bar
$ ./lib/dev fs_dirname foo/bar/.ipsum
foo/bar
$ ./lib/dev fs_dirname foo/bar//.ipsum
foo/bar
$ ./lib/dev fs_dirname foo/bar/////.ipsum
foo/bar
$ ./lib/dev fs_dirname /some/example/path/to/this_is_a_file
/some/example/path/to
```
