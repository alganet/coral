shell_assertion
===============

Runs a console session and verifies if the output matches it.

For example, you might have a session saved as `session.txt`:

```txt file session.txt
$ echo 1
1
```

Then you can run it using `shell_assertion`:

```console test
$ ./lib/dev shell_assertion session.txt
  $ echo 1
  1
```

The session will be replayed in cased of success. In case of any error,
a diff will be presented, as in the `errordiff.txt` file:

```txt file errordiff.txt
$ echo 1
Not 1
```

```console test
$ ./lib/dev shell_assertion errordiff.txt
  $ echo 1
+ 1
- Not 1
```
