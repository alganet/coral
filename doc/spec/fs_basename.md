fs_basename
===========

Extracts the file name portion of a path and prints it out.

	        dirname           filename
	           |                 |
       __________________   ____________
	 /some/example/path/to/this_is_a_file

Let's try some examples:

```console test
$ ./lib/dev fs_basename foo/bar
bar
$ ./lib/dev fs_basename foo/bar/baz
baz
$ ./lib/dev fs_basename foo/bar/baz.lorem
baz.lorem
$ ./lib/dev fs_basename foo/bar/.ipsum
.ipsum
$ ./lib/dev fs_basename foo/bar//.ipsum
.ipsum
$ ./lib/dev fs_basename foo/bar/////.ipsum
.ipsum
$ ./lib/dev fs_basename /some/example/path/to/this_is_a_file
this_is_a_file
```
