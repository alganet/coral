# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Arr_noargs () {
	Arr
	eval deref=\$$_R
	tap_assert "0" "$deref"
}

test_Arr_unary_zerolength () {
	Arr ""
	eval deref=\$$_R
	tap_assert "1" "$deref"
}

test_Arr_simple () {
	Arr foo bar baz
	eval deref=\$$_R
	tap_assert "3" "$deref"
}
