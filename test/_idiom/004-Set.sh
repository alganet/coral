# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Set_noargs () {
	Set
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Set_unary_zerolength () {
	Set ""
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Set_simple () {
	Set foo bar baz
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz" "$deref"
}

test_Set_uniqueness_A () {
	Set foo foo bar
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar" "$deref"
}

test_Set_uniqueness_B () {
	Set foo bar foo
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar" "$deref"
}

test_Set_uniqueness_C () {
	Set bar foo foo
	eval deref=\$$_R
	tap_assert "bar${__EOL__}foo" "$deref"
}

test_Set_add_to_existing () {
	Set foo bar baz
	Set_add $_R baz foo qux bar qux
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz${__EOL__}qux" "$deref"
}

test_Set_add_to_existing_empty_list () {
	Set
	Set_add $_R foo bar baz
	eval deref=\$$_R
	tap_assert "foo${__EOL__}bar${__EOL__}baz" "$deref"
}
