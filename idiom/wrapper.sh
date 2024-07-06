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

test $# = 0 || require "$1"
shift
unset -f require
"${REPLY:-}" "${@:-}"
