# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Txt_noargs () {
	Txt
	dump $_R
	tap_assert "''" "$REPLY"
}

test_Txt_unary_zerolength () {
	Txt ""
	dump $_R
	tap_assert "''" "$REPLY"
}

test_Txt_simple () {
	Txt "Some text"
	dump $_R
	tap_assert "'Some text'" "$REPLY"
}

test_Txt_add () {
	Txt "Some text"
	dump $_R
	Txt_add $_R " and some more"
	dump $_R
	tap_assert "'Some text and some more'" "$REPLY"
}

test_Txt_add_to_empty_string () {
	Txt
	dump $_R
	Txt_add $_R "Hi"
	dump $_R
	tap_assert "'Hi'" "$REPLY"
}
