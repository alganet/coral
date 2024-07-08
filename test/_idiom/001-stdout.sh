# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

test_write () {
	tap_assert ''                    "$(_write)"
	tap_assert '\0101'               "$(_write '\0101')"
	tap_assert 'x\\x'                "$(_write 'x\\x')"
	tap_assert 'x\nx'                "$(_write 'x\nx')"
	tap_assert 'x\tx'                "$(_write 'x\tx')"
	tap_assert "123123"              "$(_write 123; _write 123)"
	tap_assert "123${__EOL__}456123" "$(_write 123 456; _write 123)"
}

test_print () {
	tap_assert ''                    "$(_print)"
	tap_assert 'A'                   "$(_print '\0101')"
	tap_assert 'x\x'                 "$(_print 'x\\x')"
	tap_assert "x${__EOL__}x"        "$(_print 'x\nx')"
	tap_assert "x${__TAB__}x"        "$(_print 'x\tx')"
	tap_assert "123123"              "$(_print 123; _print 123)"
	tap_assert "123${__EOL__}456123" "$(_print 123 456; _print 123)"
}

test_inline_unary_zerolength () {
	tap_assert '' "$(_inline; _inline)"
}

test_inline () {
	tap_assert 'foo\nbar' "$(_inline "foo${__EOL__}bar")"
}
