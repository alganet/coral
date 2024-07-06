# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Set_noargs () {
    Set
    eval deref=\$$_R
    tap_assert "${__EOL__}" "$deref"
}

test_Set_unary_zerolength () {
    Set ""
    eval deref=\$$_R
    tap_assert "${__EOL__}" "$deref"
}

test_Set_simple () {
    Set foo bar baz
    eval deref=\$$_R
    tap_assert "${__EOL__}foo${__EOL__}bar${__EOL__}baz" "$deref"
}

test_Set_uniqueness_A () {
    Set foo foo bar
    eval deref=\$$_R
    tap_assert "${__EOL__}foo${__EOL__}bar" "$deref"
}

test_Set_uniqueness_B () {
    Set foo bar foo
    eval deref=\$$_R
    tap_assert "${__EOL__}foo${__EOL__}bar" "$deref"
}

test_Set_uniqueness_C () {
    Set bar foo foo
    eval deref=\$$_R
    tap_assert "${__EOL__}bar${__EOL__}foo" "$deref"
}
