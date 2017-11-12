fs_dirname
==========

```console test 
$ my_dirname="$(./lib/dev fs_dirname foo/bar)"
$ test "${my_dirname}" = "foo" || echo 'Fail'
```

```console test 
$ my_dirname="$(./lib/dev fs_dirname foo/bar/baz)"
$ test "${my_dirname}" = "foo/bar" || echo 'Fail'
```
