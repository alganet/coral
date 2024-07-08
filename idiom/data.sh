# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

# Pseudo Data Structures

# Variables in this file are intentionally short because
# it is eval heavy and it matters for some shells.

_T=0 _L=0 _S=0 _A=0 # Some counters for Txt, Lst, Set and Arr

# Evaluates an expression within brackets
exp () {
    local _t=
    local _e=

	case $# in
		0) Txt '' ; return ;;
		1) Txt $1 ; return ;;
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
			_[TLSA]*)
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
		_[TLSA]*) _R=$_e ;;
		       *) eval $_e ;;
	esac
}

# Evaluates an expression and assigns the result to a variable
val () {
	local _n=$1 _o=$2
	shift 2
	case $_o in
		\=)  exp ${@:-} ; eval $_n=\$_R ;;
		\=@) eval $_n=\$$1 ;;
	esac
}

# Dumps the internal values of a given pseudodatastructure recursively
dump () {
    local dump= item= len=0 count=0
    case $1 in
        _T*) eval dump=\"\'\$$1\'\" ;;
		_[LS]*)
			eval "REPLY=\"\$$1\""
			case $1 in
				_L*) dump="[ Lst " ;;
				_S*) dump="[ Set " ;;
			esac
			for item in $REPLY
			do
				dump $item
				dump="$dump$REPLY "
			done
			dump="$dump]"
			;;
		_A*)
			eval "len=\"\$(($1))\""
			dump="[ Arr "
			while test $count -lt $len
			do
				eval "dump \$$1i$count"
				dump="$dump$REPLY "
				count=$((count + 1))
			done
			dump="$dump]"
			;;
    esac
    REPLY="$dump"
}

toenv () {
    local dump= item= len=0 count=0
    case $1 in
        _T*) eval dump=\"$1=\'\$$1\'\" ;;
		_[LS]*)
			dump=
			eval "REPLY=\"\$$1\""
			for item in $REPLY
			do
				toenv $item
				dump="$dump$REPLY${__EOL__}"
			done
			eval "dump=\"\${dump}$1='\$$1'\"\${__EOL__}"
			;;
		_A*)
			eval dump=\"$1=\'\$$1\'\${__EOL__}\"
			eval "len=\"\$(($1))\""
			while test $count -lt $len
			do
				eval "toenv \$$1i$count"
				eval "dump=\"\${dump}$1i$count=\$$1i$count\"\${__EOL__}"
				dump="$dump$REPLY${__EOL__}"
				count=$((count + 1))
			done
			;;
    esac
    REPLY="$dump"
}

# The Txt pseudotype constructor
Txt () {
	_T=$((_T + 1))
	_R=_T$_T
	eval "$_R=\${*:-}"
}

Txt_add () {
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
	eval "$_R=\"\$$_R\${$_R:+\$__EOL__}\$*\""
}

# The Set pseudotype constructor
Set () {
	_S=$((_S + 1))
	_R=_S$_S
	eval "$_R="
	Set_add $_R "${@:-}"
}

Set_add () {
	_R="$1"
	while test $# -gt 1
	do shift ; eval "
		case \"\$__EOL__\$$_R\$__EOL__\" in
			*\"\$__EOL__\$1\$__EOL__\"*);;
			*)$_R=\"\$$_R\${$_R:+\$__EOL__}\$1\";;
		esac"
	done
}

# The Arr pseudotype constructor
Arr () {
	_A=$((_A + 1))
	_R=_A$_A
	eval "$_R=0"
	test $# -lt 1 || Arr_add $_R "$@"
}

Arr_add () {
	_R=$1
	eval "$_R=$(($_R + $# - 1))"
	while test $# -gt 1
	do shift ; eval "${_R}i$(($_R - $#))=\$1"
	done
}
