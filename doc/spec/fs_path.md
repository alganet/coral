fs_path
=======

```console test
$ > ./SOME_FILE.txt
$ ./lib/dev fs_path SOME_FILE.txt .
./SOME_FILE.txt
```

```console test
$ mkdir -p some_dir
$ > ./some_dir/ANOTHER_FILE.txt
$ ./lib/dev fs_path ANOTHER_FILE.txt ./some_dir:.
./some_dir/ANOTHER_FILE.txt
```

```console test
$ mkdir -p some_dir
$ > ./some_dir/DUPLICATE.txt
$ > ./DUPLICATE.txt
$ ./lib/dev fs_path DUPLICATE.txt ./some_dir:.
./some_dir/DUPLICATE.txt
$ ./lib/dev fs_path DUPLICATE.txt .:./some_dir
./DUPLICATE.txt
```

```console test
$ ./lib/dev fs_path sh | sed -n '/sh/p' > ./fs_path_for_sh
$ test -n "$(./lib/dev fs_lines ./fs_path_for_sh)" || echo 'Fail'
```

