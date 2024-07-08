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
	eval deref=\$${_R}i0
	tap_assert "" "$deref"
}

test_Arr_simple () {
	Arr foo bar baz
	eval deref=\$$_R
	tap_assert "3" "$deref"
	eval deref=\$${_R}i0
	tap_assert "foo" "$deref"
	eval deref=\$${_R}i1
	tap_assert "bar" "$deref"
	eval deref=\$${_R}i2
	tap_assert "baz" "$deref"
}

test_Arr_add_to_existing () {
	Arr foo bar baz
	Arr_add $_R qux
	eval deref=\$$_R
	tap_assert "4" "$deref"
	eval deref=\$${_R}i3
	tap_assert "qux" "$deref"
}

test_Arr_add_to_existing_empty_list () {
	Arr
	Arr_add $_R foo bar baz
	eval deref=\$$_R
	tap_assert "3" "$deref"
	eval deref=\$${_R}i0
	tap_assert "foo" "$deref"
	eval deref=\$${_R}i1
	tap_assert "bar" "$deref"
	eval deref=\$${_R}i2
	tap_assert "baz" "$deref"
}
