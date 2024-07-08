# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Txt_noargs () {
	Txt
	eval deref=\$$_R
	tap_assert "$deref" ""
}

test_Txt_unary_zerolength () {
	Txt ""
	eval deref=\$$_R
	tap_assert "$deref" ""
}

test_Txt_simple () {
	Txt "Some text"
	eval deref=\$$_R
	tap_assert "$deref" "Some text"
}
