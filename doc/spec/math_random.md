math_random
===========

```console test 
$ my_random="$(./lib/dev math_random)"
$ test -n "${my_random}" || echo 'Fail Empty number'
$ test "${my_random}" = "$(printf %s "${my_random}" | sed 's/[^0-9]//g')"
$ test $? = 0 || echo "Fail: non-numeric chars on ${my_random}"
```
