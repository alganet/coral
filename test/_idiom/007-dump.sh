# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_dump_Txt () {
    val first_name = "Lorem"
	dump $first_name
    tap_assert "'Lorem'" "$REPLY"
}

test_dump_Lst () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Lst $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Lst 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_dump_Set () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Set $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Set 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_dump_Arr () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Arr $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Arr 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_dump_nested_Lst () {
	val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Lst $first_name $last_name ]
	val person = [ Arr $name_parts ]
	dump $person
	tap_assert "[ Arr [ Lst 'Lorem' 'Ipsum' ] ]" "$REPLY"
}
