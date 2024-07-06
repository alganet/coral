# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

require () {
	set -- "$1" "${1%%_*}"
	set -- "$2" "${1#"${2}_"}"
	. "${__LIB__}/module/$1/$2.sh"
	REPLY="${1}_${2}"
}
