module_assemble
===============

Assembles modules and their dependencies into standalone files.

---

Let's start first with a simple module:

```sh file mymodule.sh
mymodule ()
{
	echo 1
}
```

The `module_assemble` function takes two arguments: an input module
name and an option output module name.


```console test
$ MODULE=mymodule
$ ./lib/dev module_assemble $MODULE $MODULE
$ echo $MODULE
mymodule
$ sh ./mymodule
1
```

If no output is provided, the assembled module will be printed out.

```console test
$ MODULE=mymodule
$ assemble_path=: ./lib/dev module_assemble $MODULE
#!/bin/sh

##
 # script/support - silently set sane options for all shells
 ##

# Options for all shells
#
# -e: Exit if any command has an uncaught error code
# -u: Exit on any use of an undefined variable
# -f: Do not expand glob patterns
set -euf

# Mimic local variables on ksh by aliasing it to typeset
#
# This command is ignored by shells other than ksh
#
if ( test -n "${KSH_VERSION:-}" &&
     test -z "${KSH_VERSION##*Version AJM*}" ) ||
     test -n "${YASH_VERSION:-}"
then
	alias local=typeset
elif test -n "${BASH_VERSION-}"
then
	set -o posix
elif test -n "${ZSH_VERSION-}"
then
	# Unset options for zsh to make it more portable
	#
	# NO_MATCH: Avoid expanding extra filename patterns
	# NO_SH_WORD_SPLIT: Make the word split on zsh behave like POSIX
	#
	# This command is ignored in shells other than zsh.
	#
	unsetopt GLOB NO_MATCH NO_SH_WORD_SPLIT >/dev/null 2>&1 || :
fi
entrypoint='mymodule'
require_loaded=' mymodule.sh '
require_path=":"
require () ( : )
mymodule ()
{
	echo 1
}

#!/bin/sh

##
 # script/entrypoint - a modular command runner
 ##

# Run command named by the entrypoint variable or nothing (the : command)
${entrypoint:-:} "${@:-}"
```
