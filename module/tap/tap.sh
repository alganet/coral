# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

tap_assert () {
	if ! test "x$1" = "x$2"
	then
		_print "  # expected: "
		_inline "${1:-"<empty>"}"
		_print "  #   result: "
		_inline "${2:-"<empty>"}"
	fi
}

tap_tap () {
	local \
		input="${1:-"test/*/*"}" file= line= tline= lineno= match= tests= test_spec= \
		errors= test_name= test_count=0 fail_count=0

	if test -f "$input"
	then REPLY="$input"
	else _glob "$input.sh"
	fi

	_print "TAP version 14\n"
	for file in $REPLY
	do
		lineno=0
		val tests = [ Set ]

		while read -r line || test -n "$line"
		do
			lineno=$((lineno + 1))
			match="${line%" () {"}"
			if test "$line" = "$match () {"
			then
				val match = "$match"
				val tline = "${lineno}"
				val test_spec = [ Lst $match $tline ]
				Set_add $tests $test_spec
			fi
		done < "$file"

		. $file

		val tests =@ $tests
		for test_spec in $tests
		do
			val test_spec =@ $test_spec
			set -- $test_spec
			val test_name =@ $1
			val test_line =@ $2
			test_count=$((test_count + 1))
			errors="$(set +x; $test_name 2>&1 || :)"

			if test -z "$errors"
			then _print "ok ${test_count} - $test_name\n"
			else
				fail_count=$((fail_count + 1))

				_print \
					"not ok ${test_count} - $test_name" \
					"${errors}" \
					"  #       at: $file:$test_line${__TAB__}\n\n"
			fi

		done
	done

	_print "1..${test_count}\n"
	local test_results="($((test_count - fail_count))/$test_count)"
	if test "$fail_count" -gt 0
	then
		_print "# FAIL $test_results\n"
		return 1
	else
		_print "# PASS $test_results\n"
		return 0
	fi
}
