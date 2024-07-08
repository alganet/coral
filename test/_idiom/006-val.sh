# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_val_noargs () {
	local my_variable=
	val my_variable =
	eval deref=\$$my_variable
	tap_assert "" "$deref"
}

test_val_unary_zerolength () {
	local my_variable=
	val my_variable = ""
	eval deref=\$$my_variable
	tap_assert "" "$deref"
}

test_val_simple () {
	local my_variable=
	val my_variable = "Some text"
	eval deref=\$$my_variable
	tap_assert "Some text" "$deref"
}
