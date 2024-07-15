# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Lst_noargs () {
	Lst
	dump $_R
	tap_assert "[ Lst ]" "$REPLY"
}

test_Lst_unary_zerolength () {
	Lst ""
	dump $_R
	tap_assert "[ Lst ]" "$REPLY"
}

test_Lst_simple () {
	local lst=
	val lst = Lst =foo =bar =baz
	dump $lst
	tap_assert "[ Lst 'foo' 'bar' 'baz' ]" "$REPLY"
}

test_Lst_add_to_existing () {
	local lst= extra=
	val lst = Lst =foo =bar =baz
	val extra = "qux"
	Lst_add $_R $extra
	dump $lst
	tap_assert "[ Lst 'foo' 'bar' 'baz' ]" "$REPLY"
}

test_Lst_add_to_existing_empty_list () {
	local lst= a= b= c=
	val a = foo
	val b = bar
	val c = baz
	val lst = [ Lst ]
	Lst_add $_R $a $b $c
	dump $lst
	tap_assert "[ Lst 'foo' 'bar' 'baz' ]" "$REPLY"
}
