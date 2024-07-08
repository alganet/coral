# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_Map_noargs () {
	Map
	eval deref=\$$_R
	tap_assert "" "$deref"
}

test_Map_simple () {
	Map :mykey myvalue
	eval deref=\$$_R
	tap_assert "mykey" "$deref"
	eval deref=\$${_R}imykey
	tap_assert "myvalue" "$deref"
}

test_Map_multiple_keys () {
	Map :mykey myvalue :mysecond anothervalue
	eval deref=\$$_R
	tap_assert "mykey${__EOL__}mysecond" "$deref"
	eval deref=\$${_R}imysecond
	tap_assert "anothervalue" "$deref"
}

test_Map_add_to_existing () {
	Map :mykey myvalue
	Map_add $_R :mysecond anothervalue
	eval deref=\$$_R
	tap_assert "mykey${__EOL__}mysecond" "$deref"
	eval deref=\$${_R}imysecond
	tap_assert "anothervalue" "$deref"
}

test_Map_key_uniqueness_retains_last_value () {
	Map :mykey myvalue :mykey whichvalue
	eval deref=\$$_R
	tap_assert "mykey" "$deref"
	eval deref=\$${_R}imykey
	tap_assert "whichvalue" "$deref"
}
