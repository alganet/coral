#!/usr/bin/env sh

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
if test -n "${KSH_VERSION:-}" &&
   test -z "${KSH_VERSION##*Version AJM*}"
then
	alias local=typeset
elif test -n "${BASH_VERSION:-}"
then
	set -o posix
elif test -n "${ZSH_VERSION-}"
then
	# Unset options for zsh to make it more portable
	#
	# NO_IGNORE_BRACES: Make it ignore proprietary braces syntax
	# NO_MATCH: Avoid expanding extra filename patterns
	# NO_SHWORDSPLIT: Make the word split on zsh behave like POSIX
	# BAD_PATTERN: Ignore errors for zsh-specific syntax
	#
	# This command is ignored in shells other than zsh.
	#
	unsetopt \
		NO_IGNORE_BRACES \
		NO_MATCH \
		NO_SH_WORD_SPLIT \
		BAD_PATTERN >/dev/null 2>&1 || :
fi

