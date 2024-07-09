# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

# Characters that are weird to represent should use these variables.
__TAB__="	"
__EOL__="
"

LC_ALL=C     # We want to treat multibyte strings as individual bytes
IFS=$__EOL__ # Don't break my variables by spaces
PATH=""      # We don't need other programs

_quiet () { "$@" >/dev/null 2>&1; }  # Runs with no stdout/stderr
_noerr () { "$@" 2>/dev/null || :; } # Runs and ignores failures and stderr
_reply () { eval "REPLY='${*:-}'"; } # Feeds a reply
_has () { _quiet command -v "$1"; }  # Checks if a command is available

set -euf

# Feature-detects glob stuff
if _quiet setopt sh_word_split no_glob no_multios ignore_braces
then _glob () { setopt glob glob_subst; _reply $@; unsetopt glob; }
else _glob () { set +f; _reply $@; set -f; }
fi

# Feature-detects printing functions
REPLY="$(
	_noerr printf %s%b "\\061 " "\\062 "
	_noerr echo -n -E "\\063 "
)"

case "$REPLY" in
"\\061 2 "*)
	_print () { printf %b "${1:-}"; }
	_write () { printf %s "${1:-}"; }
	;;
"\\063 ")
	_print () { echo -n -e "${1:-}"; }
	_write () { echo -n -E "${1:-}"; }
	;;
*)
	_print () { echo -n "${1:-}"; }
	# Only posh will use this, as it doesn't have a non-escaping builtin echo
	_write () {
		IFS='\'
		set -- $1
		IFS=$__EOL__
		echo -n "$1"
		shift
		while test $# -gt 0
		do
			echo -n "\\\\$1"
			shift
		done
	}
	;;
esac

# Escapes multiple lines into a single one with \n in between
_inline () {
	set -- ${*:-}
	test $# -gt 0 || return 0;
	while test $# -gt 1
	do
		_write "$1\\n"
		shift
	done
	_write "$1${__EOL__}"
}

# Shim for local
if _has alias && _has typeset
then alias local=typeset
fi

REPLY=
