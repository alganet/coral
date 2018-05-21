spec_doc
========

It runs Markdown specifications and reports their results as [TAP][TAP].
It has only three features:

 - **File Mocking**: To allow placing stubs and mock files during the runs.
 - **Console Simulation**: To emulate and verify console interactions.
 - **Setup Code**: To inject functions or variables in test sessions.

All other functionality relies on Markdown and Shell Script themselves.

---

A specification is a program written in [Markdown][MD]. [Code blocks][CB] are
used to include formal code examples.

The command will run these files as a test suite, using blocks
with special [info strings][IS] to play different roles in the test suite.

Normal Blocks
-------------

Standard blocks are ignored.

	```
	This is a block, but has no info string. It will be ignored by coral spec.
	```

Language blocks are also ignored.

	```sh
	This is a shell block, but language alone is not enough to trigger a role.
	```

Mocking files
-------------

You can simulate files present in the disk during the time of the test
by using the `file` infostring:


	```txt file example.txt
	A "file" block will save that file in the working directory when running
	tests.
	```

These files will be removed automatically after the test is done (at
the end of the document).

Simulating Console Interactions
-------------------------------

You can use `console test` infostrings to simulate console interactions.
It checks if the real output matches the expected in the specification.

	```console test
	$ echo 'A console test will run commands and check their outputs.'
	A console test will run commands and check their outputs.
	```

	```console test
	$ echo 1
	This would fail. This is not the expected output for `echo 1`
	```

All console interactions should support variables persistency:

	```console test
	$ foo=bar
	```

	Then something...

	```console test
	$ echo $foo
	bar
	```

Return codes are also preserved, allowing a fluent writing style:

	```console test
	$ do_something
	```

	We will check if it worked....

	```console test
	$ echo $?
	0
	```

Ignoring Output
---------------

If you want to run a task, check if it has returned a success code
but ignore its output, you can use the `console task` infostring:

	```console task
	$ echo 'A console task ignores output'
	This will not fail!
	```

Of course you can also direct it to `/dev/null`, but the main difference
is that when some `task` fails, the error will still present the failed
output.

Setup Code
----------

A setup block can be used to declare functions, define variables or load
scripts.

	```sh setup
	echo 'This will run before each console execution'
	```

Running Tests
-------------

You can either use a compiled version or load it using `./lib/dev`:

```console task
$ ./lib/dev spec_doc doc/spec/fs_basename.md
# using	'sh'
#
# file	'doc/spec/fs_basename.md'
ok	1 - ./lib/dev fs_basename foo/bar
ok	2 - ./lib/dev fs_basename foo/bar/baz
ok	3 - ./lib/dev fs_basename foo/bar/baz.lorem
ok	4 - ./lib/dev fs_basename foo/bar/.ipsum
ok	5 - ./lib/dev fs_basename foo/bar//.ipsum
ok	6 - ./lib/dev fs_basename foo/bar/////.ipsum
ok	7 - ./lib/dev fs_basename /some/example/path/to/this_is_a_file
# SUCCESS
1..8
```
Multiple files can be fed to the command, which also will make the
TAP test counter consider all of them:

```console task
$ ./lib/dev spec_doc doc/spec/fs_basename.md doc/spec/fs_dirname.md
# using	'sh'
#
# file	'doc/spec/fs_basename.md'
ok	1 - ./lib/dev fs_basename foo/bar
ok	2 - ./lib/dev fs_basename foo/bar/baz
ok	3 - ./lib/dev fs_basename foo/bar/baz.lorem
ok	4 - ./lib/dev fs_basename foo/bar/.ipsum
ok	5 - ./lib/dev fs_basename foo/bar//.ipsum
ok	6 - ./lib/dev fs_basename foo/bar/////.ipsum
ok	7 - ./lib/dev fs_basename /some/example/path/to/this_is_a_file
# file	'doc/spec/fs_dirname.md'
ok	8 - ./lib/dev fs_dirname foo/bar
ok	9 - ./lib/dev fs_dirname foo/bar/baz
ok	10 - ./lib/dev fs_dirname foo/bar/baz.lorem
ok	11 - ./lib/dev fs_dirname foo/bar/.ipsum
ok	12 - ./lib/dev fs_dirname foo/bar//.ipsum
ok	13 - ./lib/dev fs_dirname foo/bar/////.ipsum
ok	14 - ./lib/dev fs_dirname /some/example/path/to/this_is_a_file
# SUCCESS
1..15
```

The output is TAP-compliant and can be fet to any harness system
directly or saved to a file.

Failures will include a diff of the output that didn't matched:

```console
$ ./lib/dev spec_doc doc/spec/fs_basename.md
# using	'sh'
#
# file	'doc/spec/fs_basename.md'
ok	1 - ./lib/dev fs_basename foo/bar
not ok	2 - ./lib/dev fs_basename foo/bar/baz
# Failure on doc/spec/fs_basename.md line 13
1c1
< ba
---
> baz
ok	3 - ./lib/dev fs_basename foo/bar/baz.lorem
ok	4 - ./lib/dev fs_basename foo/bar/.ipsum
ok	5 - ./lib/dev fs_basename foo/bar//.ipsum
ok	6 - ./lib/dev fs_basename foo/bar/////.ipsum
ok	7 - ./lib/dev fs_basename /some/example/path/to/this_is_a_file
# FAILURE (1 of 8 assertions failed)
1..8
```

[MD]: http://commonmark.org/help/
[CB]: http://commonmark.org/help/
[IS]: http://spec.commonmark.org/0.12/#info-string
[TAP]: https://testanything.org/tap-specification.html
