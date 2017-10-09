support Module
==============

It contains settings to make all shells behave similarly.

### Bail on errors

The module will configure any shell to exit if a command returns an untreated
error code.

```sh file bail_erros.sh

. "./lib/require/support"

# This command should fail before echo is sent
false

echo 'This is never shown'
```


```console
$ ${SHELL} ./bail_erros.sh
$ echo $?
1
```

### Bail on undefined vars

Using undefined variables will also lead to an error.

```sh file bail_erros.sh

. "./lib/require/support"

# This command should fail before echo is sent
echo $zoid
echo 'This is never shown'
```


```console
$ ${SHELL} ./bail_erros.sh > out 2>&1
$ test $? = 0
$ echo $?
1
```

### Support for local variables on ksh and yash

Both ksh and yash does not have the `local` keyword, which is emulated by
aliasing it to `typeset`.

```sh file local_vars.sh

. "./lib/require/support"

display_local_var ()
{
	local myvar=123

	echo $myvar
}

display_local_var
```

```console
$ ${SHELL} ./local_vars.sh
123
```

### Do not expand globs

The module ensures no glob patterns are expanded acidentally.

```sh file expand_glob.sh

. "./lib/require/support"

do_not_expand_glob ()
{
	echo foo/*
}

do_not_expand_glob
```


```console
$ mkdir -p foo/bar
$ mkdir foo/baz
$ mkdir foo/bat
$ ${SHELL} ./expand_glob.sh
foo/*
```

### Split words on for statements

Some shells do not split words without extra configuration, the `support`
module configures this automatically.

```sh file split_words.sh

. "./lib/require/support"

do_split_words ()
{
	for word in here are some words
	do
		echo $word
	done
}

do_split_words
```

```console
$ ${SHELL} ./split_words.sh
here
are
some
words
```

