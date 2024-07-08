# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Lst_noargs () {
	Lst
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Lst_unary_zerolength () {
	Lst ""
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Lst_simple () {
	Lst foo bar baz
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz" "$deref"
}
