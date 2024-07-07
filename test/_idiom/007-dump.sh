# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_dump_Txt () {
    val first_name = "Lorem"
	dump $first_name
    tap_assert "'Lorem'" "$REPLY"
}

test_toenv_Txt () {
    val first_name = "Lorem"
	local ref=$_R
	toenv $first_name
    tap_assert "$_R='Lorem'" "$REPLY"
}

test_dump_Lst () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Lst $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Lst 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_toenv_Lst () {
    val first_name = "Lorem"
	local r1=$_R
	val last_name = "Ipsum"
	local r2=$_R
	val name_parts = [ Lst $first_name $last_name ]
	local r3=$_R
	toenv $name_parts
	tap_assert "$r1='Lorem'${__EOL__}$r2='Ipsum'${__EOL__}$r3='$r1${__EOL__}$r2'${__EOL__}" "$REPLY"
}

test_dump_Set () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Set $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Set 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_toenv_Set () {
    val first_name = "Lorem"
	local r1=$_R
	val last_name = "Ipsum"
	local r2=$_R
	val name_parts = [ Set $first_name $last_name ]
	local r3=$_R
	toenv $name_parts
	tap_assert "$r1='Lorem'${__EOL__}$r2='Ipsum'${__EOL__}$r3='$r1${__EOL__}$r2'${__EOL__}" "$REPLY"
}

test_dump_Arr () {
    val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Arr $first_name $last_name ]
	dump $name_parts
	tap_assert "[ Arr 'Lorem' 'Ipsum' ]" "$REPLY"
}

test_toenv_Arr () {
    val first_name = "Lorem"
	local r1=$_R
	val last_name = "Ipsum"
	local r2=$_R
	val name_parts = [ Arr $first_name $last_name ]
	local r3=$_R
	toenv $name_parts
	tap_assert "$r3='2'${__EOL__}${r3}i0=$r1${__EOL__}$r1='Lorem'${__EOL__}${r3}i1=$r2${__EOL__}$r2='Ipsum'${__EOL__}" "$REPLY"
}

test_dump_nested_Lst () {
	val first_name = "Lorem"
	val last_name = "Ipsum"
	val name_parts = [ Lst $first_name $last_name ]
	val person = [ Arr $name_parts ]
	dump $person
	tap_assert "[ Arr [ Lst 'Lorem' 'Ipsum' ] ]" "$REPLY"
}
