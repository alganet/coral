fs_path
=======

Finds files in a list of paths.


---

First, let's create some folders and files:

```console test
$ mkdir -p some_dir
$ printf '' > ./some_dir/SOME_FILE.txt
```

We can then use the fs_path function to look for files there:

```console test
$ ./lib/dev fs_path SOME_FILE.txt ./some_dir:.
./some_dir/SOME_FILE.txt
```

We can also use it to look for a single file in multiple folders. It
will return the first file it can find:

```console test
$ mkdir -p some_dir
$ printf '' > ./some_dir/DUPLICATE.txt
$ printf '' > ./DUPLICATE.txt
$ ./lib/dev fs_path DUPLICATE.txt ./some_dir:.
./some_dir/DUPLICATE.txt
$ ./lib/dev fs_path DUPLICATE.txt .:./some_dir
./DUPLICATE.txt
```

When no list of paths is used, the  `$PATH` variable will be used
instead:

```console task
$ ./lib/dev fs_path sh
/bin/sh
```

Using the current folder as path should work

```console test
$ printf '' > ./SOME_FILE.txt
$ ./lib/dev fs_path SOME_FILE.txt .
./SOME_FILE.txt
```
