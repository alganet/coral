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

test_Lst_add_to_existing () {
	Lst foo bar baz
	Lst_add $_R qux
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz${__EOL__}qux" "$deref"
}

test_Lst_add_to_existing_empty_list () {
	Lst
	Lst_add $_R foo bar baz
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz" "$deref"
}
