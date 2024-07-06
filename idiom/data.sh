# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

# Pseudo Data Structures

_S=0 _L=0 _S=0 _A=0 # Some counters for Str, Lst, Set and Arr

# Evaluates an expression within brackets
exp () {
    local _t=
    local _e=

	case $# in
		0) Str '' ; return ;;
		1) Str $1 ; return ;;
		2) ${@:-} ; return ;;
	esac

    set -- \: "$@"
	for _t in "$@"
	do
		case "$_t" in
			\:)
				shift $#
				;;
			\[)
				set -- "$_e" "${@:-}"
				_e=
				;;
			\])
				eval $_e
				_e="${1:-}${1:+ }$_R"
				shift
				;;
			_[SLSA]*)
				_e="${_e:-}${_e:+ }$_t"
				;;
			[A-Z][a-z]*)
				test -z "$_e" &&
					_e="${_e:-}${_e:+ }$_t" ||
					eval "_e=\"\${_e:-}\${_e:+ }\$$_t\""
				;;
			*)
				ERROR $_t
				;;
		esac
	done
	case $_e in
		_[SLSA]*) _R=$_e ;;
		       *) eval $_e ;;
	esac
}

# Evaluates an expression and assigns the result to a variable
val () {
	local _n=$1 _o=$2
	shift 2
	exp ${@:-}
	case $_o in
		\=) eval $_n=\$_R ;;
	esac
}

# The Str pseudotype constructor
Str () {
	_S=$((_S + 1))
	_R=_S$_S
	eval "$_R=\${*:-}"
}

Str_add () {
	eval "$_R=\${*:-}"
}

# The Lst pseudotype constructor
Lst () {
	_L=$((_L + 1))
	_R=_L$_L
	eval "$_R=\"\${$_R:-}\${*:-}\""
}

Lst_add () {
	_R=$1
	shift
	eval "$_R=\"\${$_R:-}\$*\""
}

# The Set pseudotype constructor
Set () {
	_S=$((_S + 1))
	_R=_S$_S
	eval "$_R="
	Set_add $_R "${@:-}"
}

Set_add () {
	_R=$1
	while test $# -gt 1
	do shift ; eval "
		case \"\$$_R\$__EOL__\" in
			*\"\$__EOL__\$1\$__EOL__\"*);;
			*)$_R=\"\$$_R\$__EOL__\$1\";;
		esac"
	done
}

# The Arr pseudotype constructor
Arr () {
	_A=$((_A + 1))
	_R=_A$_A
	eval "$_R=-1"
	if test $# -gt 0
	then
		eval "$_R=-1"
		Arr_add $_R "$@"
	else
		eval "$_R=0"
	fi
}

Arr_add () {
	_R=$1
	eval "$_R=$(($_R + $#))"
	while test $# -gt 1
	do shift ; eval "${_R}i$(($_R - $#))=\$1"
	done
}
