require 'tempdir.sh'

spec ()
{
	spec_command_"${@:-}"
}

spec_command_ ()
{
	:
}

spec_command_run()
{
	local target="${1:-.}"
	local spec_shell="${spec_shell:-sh}"

	echo "# Running specification for ${target} with ${spec_shell}"
	echo "# "

	cat "${target}" | spec_parse "$(tempdir 'spec')"
}

spec_parse ()
{
	local spec_directory="${1}"
	local line=
	local open_fence=
	local possible_fence=
	local line_number=1
	local line_last_open_fence=0
	local test_number=0
	local fail_number=0
	local test_result=0

	while read -r line
	do
		possible_fence="${line#*\`\`\`}"

		if test -z "${open_fence}"
		then
			if test "${line}" = "\`\`\`${possible_fence}"
			then
				open_fence="${possible_fence}"
				line_last_open_fence="${line_number}"
				_spec_fence_open ${open_fence}
			else
				_spec_text_line ${open_fence}
			fi
		else
			if test "${line}" = "\`\`\`${possible_fence}"
			then
				_spec_fence_close ${open_fence}
				open_fence=
			else
				_spec_fence_line ${open_fence}
			fi
		fi

		line_number=$((line_number + 1))
	done

	if test "${fail_number}" -gt 0
	then
		echo "# FAILURE (${fail_number} of ${test_number} assertions failed)"
		test_result=1
	fi

	echo "1..${test_number}"

	return "${test_result}"
}

_spec_fence_open ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "file" = "${key}"
	then
		printf '' > "${spec_directory}/${value}"
	elif test "console" = "${language}"
	then
		printf '' > "${spec_directory}/console"
	fi
}

_spec_fence_line ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "file" = "${key}"
	then
		echo "$line" >> "${spec_directory}/${value}"
	elif test "console" = "${language}"
	then
		echo "$line" >> "${spec_directory}/console"
	fi
}

_spec_fence_close ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "console" = "${language}"
	then
		_spec_run_console
	fi
}

_spec_run_console ()
{
	local previous="${PWD}"
	local message=
	local instructions=
	local result=true
	local result_code=0
	local expectation=
	local title=
	local message_line=1
	local last_command_line=0

	cd "${spec_directory}"

	while read -r message
	do
		if test "\$ # ${message#*\$ # }" = "${message}"
		then
			local title="${message#*\$ # }"
		elif test "\$ ./${message#*\$ ./}" = "${message}" &&
			 test -x "./${message#*\$ ./}"
		then
			_spec_report_single_result
			last_command_line="${message_line}"
			spec_file="${message#*\$ ./}"
			instructions="$(cat "${spec_file}")"
			test_number=$((test_number + 1))
			result_code=$(_spec_run_external 2>/dev/null)
			instructions="./${spec_file}"
			spec_file=
			result="$(cat result)"

			expectation=
		elif test "\$ ${message#*\$ }" = "${message}"
		then
			_spec_report_single_result
			last_command_line="${message_line}"
			instructions="${message#*\$ }"
			test_number=$((test_number + 1))
			result_code=$(_spec_run_external 2>/dev/null)
			result="$(cat result)"

			expectation=
		else
			_spec_collect_expectation
		fi
		message_line=$((message_line + 1))
	done < "console"

	_spec_report_single_result
	instructions="${message#*\$ }"

	cd "${previous}"
}

_spec_run_external ()
{
	local OLDPS4="${PS4:-}"
	local extra_setup=":"

	set +e

	${spec_shell} <<-EXTERNAL > result 2>&1
		test 'last_command_success=0' = "last_command_success=${result_code}"
		${instructions}
	EXTERNAL

	result_code="$?"
	set -e
	echo "$result_code"
}

_spec_collect_expectation ()
{
	if test -z "${expectation}"
	then
		expectation="${message}"
	else
		expectation=$(printf %s\\n "${expectation}" "$message")
	fi
}

_spec_report_single_result ()
{
	local line_report="${test_number} - ${title:-${instructions}}"

	if test "${expectation}" = "${result}"
	then
		echo "ok	${line_report}"
		instructions=
	elif test ! -z "${instructions}"
	then
		fail_number=$((fail_number + 1))
		error_line=$((${line_last_open_fence} + ${last_command_line}))
		echo
		echo "not ok	${line_report}"
		echo "# Failure on ${target} line ${error_line}"
		echo "# Output"
		echo "${result}" | sed 's/.*/# +	&/'
		echo "# Expected"
		echo "${expectation}" | sed 's/.*/# -	&/'
		echo
	fi
}

_spec_text_line ()
{
	:
}

