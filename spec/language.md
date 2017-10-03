The Shell Language
==================

### Return Codes

Every command and function execution on the shell have a return code. A `0`
return code means success.

You can access the return code of the last command executed using the variable `$?`:

```console
$ echo 'This always works'
This always works
$ echo $?
0
```

The `true` and `false` commands always return `0` and `1` respectively:

```console
$ true
$ echo $?
0
$ false
$ echo $?
1
```


### The `test` command

Often a built-in (embedded in the shell), sometimes available as a standalone
command, `test` can perform operator comparisons:

```console
$ test 1 = 0 # equals
$ echo $?
1
$ test 1 -gt 0 # greater than
$ echo $?
0
$ test 1 -lt 0 # lesser than
$ echo $?
1
$ test -z "" # is empty
$ echo $?
0
$ test ! -z "" # the not operator
$ echo $?
1
$ test -n "a" # not empty
$ echo $?
0
```

It can also deal with files. Let's setup some filesystem examples:

```console
$ mkdir mydir
$ touch mydir/myfile
$ echo "#!/usr/bin/env sh" > mydir/myfile
$ chmod +x mydir/myfile
$ touch mydir/otherfile
```

Now we can test for filesystem attributes:

```console
$ test -d "mydir" # is directory
$ echo $?
0
$ test -f "mydir/myfile" # is file
$ echo $?
0
$ test -x "mydir/myfile" # is executable
$ echo $?
0
$ test -r "mydir/myfile" # is readable
$ echo $?
0
$ test -w "mydir/myfile" # is writeable
$ echo $?
0
```
