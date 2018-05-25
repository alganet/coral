fs_basename
===========

Extracts the file name portion of a path and prints it out.

	        dirname           filename
	           |                 |
       __________________   ____________
	 /some/example/path/to/this_is_a_file

Sample Usage
------------

Extracting the file name `bar` from the `foo/bar` path:

```console test
$ ./lib/dev fs_basename foo/bar
bar
```

Specification
-------------

Dealing with file names:

```console test
$ ./lib/dev fs_basename foo/bar/baz
baz
$ ./lib/dev fs_basename foo/bar/baz.lorem
baz.lorem
$ ./lib/dev fs_basename foo/bar/.ipsum
.ipsum
```

Dealing with multiple and absolute slashes:

```console test
$ ./lib/dev fs_basename foo/bar//.ipsum
.ipsum
$ ./lib/dev fs_basename foo/bar/////.ipsum
.ipsum
$ ./lib/dev fs_basename /some/example/path/to/this_is_a_file
this_is_a_file
```
