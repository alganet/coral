# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Str_noargs () {
    Str
    eval deref=\$$_R
    tap_assert "$deref" ""
}

test_Str_unary_zerolength () {
    Str ""
    eval deref=\$$_R
    tap_assert "$deref" ""
}

test_Str_simple () {
	Str "Some text"
    eval deref=\$$_R
    tap_assert "$deref" "Some text"
}
