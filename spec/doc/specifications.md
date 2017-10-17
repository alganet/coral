Specifications
==============

A specification is a program written in [Markdown][MD]. [Code blocks][CB] are
used to include formal code examples. 

The `coral spec` command will run these files as a test suite, using blocks
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

Special Blocks
--------------
	
Blocks to place files in the test directory. Useful if you want to simulate
files present in the disk during the tests.

	```txt file example.txt
	A "file" block will save that file in the working directory when running
	tests.
	```
	
A block to simulate a console interaction. It checks if the real output
matches the expected in the specification.

	```console test
	$ echo 'A console test will run commands and check their outputs.'
	A console test will run commands and check their outputs.
	```

	```console test
	$ echo 1
	This would fail. This is not the expected output for `echo 1`
	```

A setup block can be used to declare functions, define variables or load
scripts.

	```sh setup
	echo 'This will run before each console execution'
	```

[MD]: http://commonmark.org/help/
[CB]: http://commonmark.org/help/
[IS]: http://spec.commonmark.org/0.12/#info-string
