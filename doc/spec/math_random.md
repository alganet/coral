math_random
===========

Generates random numbers. It will try different methods to supply a
portable implementation.

Sample Usage
------------

Generating a random number with maximum 20 chars:

```console task
$ ./lib/dev math_random
3827653
```

Specification
-------------

```console test
$ my_random="$(./lib/dev math_random)"
$ test -n "${my_random}" || echo 'Fail Empty number'
$ test "${my_random}" = "$(printf %s "${my_random}" | sed 's/[^0-9]//g')"
$ test $? = 0 || echo "Fail: non-numeric chars on ${my_random}"
```
