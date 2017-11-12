fs_basename
==========

```console test 
$ my_basename="$(./lib/dev fs_basename foo/bar)"
$ test "${my_basename}" = "bar" || echo 'Fail'
```

```console test 
$ my_basename="$(./lib/dev fs_basename foo/bar/baz)"
$ test "${my_basename}" = "baz" || echo 'Fail'
```
