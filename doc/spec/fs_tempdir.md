fs_tempdir
==========

```console test 
$ my_tempdir="$(./lib/dev fs_tempdir)"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}"
```

```console test
$ my_tempdir="$(./lib/dev fs_tempdir)"
$ other_tempdir="$(./lib/dev fs_tempdir)"
$ test "${my_tempdir}" != "${other_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}"
$ rm -r "${other_tempdir}"
```

```console test
$ ./lib/dev fs_tempdir > my_tempdir_path.txt
$ my_tempdir="$(./lib/dev fs_lines my_tempdir_path.txt | sed -n '/tempdir/p')"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}" my_tempdir_path.txt
```

```console test
$ ./lib/dev fs_tempdir 'zoid' > my_tempdir_path.txt
$ my_tempdir="$(./lib/dev fs_lines my_tempdir_path.txt | sed -n '/zoid/p')"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}" my_tempdir_path.txt
```

```console test
$ ./lib/dev fs_tempdir 'zoid' > my_tempdir_path.txt
$ my_tempdir="$(./lib/dev fs_lines my_tempdir_path.txt | sed -n '/zoid/p')"
$ test -n "${my_tempdir}" || echo 'Fail'
$ rm -r "${my_tempdir}" my_tempdir_path.txt
```
