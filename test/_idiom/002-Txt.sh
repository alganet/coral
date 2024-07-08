# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Txt_noargs () {
	Txt
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Txt_unary_zerolength () {
	Txt ""
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Txt_simple () {
	Txt "Some text"
	eval deref=\$$_R
	tap_assert "Some text" "$deref"
}

test_Txt_add () {
	Txt "Some text"
	eval deref=\$$_R
	Txt_add $_R " and some more"
	eval deref=\$$_R
	tap_assert "Some text and some more" "$deref"
}

test_Txt_add_to_empty_string () {
	Txt
	eval deref=\$$_R
	Txt_add $_R "Hi"
	eval deref=\$$_R
	tap_assert "Hi" "$deref"
}
