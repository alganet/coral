fs_tempdir
==========

Creates temporary directories with a partial random name, useful for
automated scripts and a safe replacement for `mktemp -d`

Sample Usage
------------

You can use a default prefix (`tempdir.sh`):

```console task
$ ./lib/dev fs_tempdir
/tmp/tempdir.sh.e8UKrp
```

...or provide your own prefix:

```console task
$ ./lib/dev fs_tempdir 'myprefix'
/tmp/myprefix.ropAjR
```

You might want to store the path in a variable:

```console task
$ my_temp="$(./lib/dev fs_tempdir 'myprefix')"
$ printf '%s\n' "${my_temp}"
/tmp/myprefix.fopyoK
```

Specification
------------

Simplest usage generates a temporary directory with a random name:

```console test
$ my_tempdir="$(./lib/dev fs_tempdir)"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}"
```

You can use a prefix name for your directory:

```console test
$ ./lib/dev fs_tempdir 'zoid' > my_tempdir_path.txt
$ my_tempdir="$(./lib/dev fs_lines my_tempdir_path.txt | sed -n '/zoid/p')"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}" my_tempdir_path.txt
```

You should be able to create multiple distinct temporary directories.

```console test
$ my_tempdir="$(./lib/dev fs_tempdir)"
$ other_tempdir="$(./lib/dev fs_tempdir)"
$ test "${my_tempdir}" != "${other_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}"
$ rm -r "${other_tempdir}"
```
