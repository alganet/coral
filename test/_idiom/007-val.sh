# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_val_noargs () {
	local my_variable=
	val my_variable =
	dump $my_variable
	tap_assert "''" "$REPLY"
}

test_val_unary_zerolength () {
	local my_variable=
	val my_variable = ""
	dump $my_variable
	tap_assert "''" "$REPLY"
}

test_val_simple () {
	local my_variable=
	val my_variable = "Some text"
	dump $my_variable
	tap_assert "'Some text'" "$REPLY"
}
