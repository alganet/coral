# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

# Shim for local on ksh93
if eval "REPLY=;_ltest(){ local REPLY=x;} 2>/dev/null" && test "$REPLY" = x
then
	unset -f ltest
	for __decl in $(typeset +f)
	do
		__name=${__decl%"()"}
		__body="$(typeset -f "$__name" || :)"
		eval "function $__name ${__body#"$__decl"}"
		case $__OPT__ in *x*) typeset -fx $__name;; esac
	done
	unset __decl __name __body
	REPLY=
fi

if test $# -gt 0
then
	if ! test -f "$1"
	then require "$1" # Main argument not a script, try to load a module
	else
		. "$1"
		REPLY=${1#*\/}
		REPLY=${REPLY%\.*}
	fi
	shift
fi
unset -f require
"${REPLY:-}" "${@:-}"
