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
		input="${1:-"test/*/*"}" file= line= lineno= match= tests= test_spec= \
        errors= test_name= test_count=0 fail_count=0

	if test -f "$input"
	then REPLY="$input"
	else _glob "$input.sh"
	fi

    _write "TAP version 14" ""
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
                val test_spec = [ Lst ]
                Set_add $test_spec $match $lineno
                Set_add $tests $test_spec
            fi
        done < "$file"

        eval "tests=\${$tests# }" # Set_all

        . $file

        for test_spec in $tests
        do
            eval "test_spec=\${$test_spec# }" # Set_all
            set -- $test_spec
            test_name="$1"
            test_line="$2"
            test_count=$((test_count + 1))
            errors="$(set +x; $test_name 2>&1 || :)"
            if test -n "$errors"
            then
                fail_count=$((fail_count + 1))
                _write "not ok ${test_count} - $test_name" \
                    "${errors}" \
                    "  #       at: $file:$test_line${__TAB__}" "" ""
            else
                _write "ok ${test_count} - $test_name" ""
            fi
        done
    done

    _write "1..${test_count}" ""
	local test_results="($((test_count - fail_count))/$test_count)"
    if test "$fail_count" -gt 0
    then
		_write "# FAIL $test_results" ""
		return 1
    else
		_write "# PASS $test_results" ""
		return 0
    fi
}
