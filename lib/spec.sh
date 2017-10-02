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
			instructions="${message#*\$ }"
			test_number=$((test_number + 1))
			_spec_run_test 2>/dev/null && result_code=$? || result_code=$?
			result="$(cat result)"

			expectation=
		else
			_spec_collect_expectation
		fi
	done < "console"

	_spec_report_single_result
	instructions="${message#*\$ }"

	cd "${previous}"
}

_spec_run_test ()
{
	local OLDPS4="${PS4:-}"
	local extra_setup=":"

	_spec_setup_debugging
	set +e
	export PS4 spec_file

	eval "$extra_setup
		set -x
		test 'last_command_success=0' = 'last_command_success=${result_code}'
		${instructions} 2>&1" 2>> debug 1> result

	result_code="$?"
	set +x
	set -e
	PS4="${OLDPS4}"
}

_spec_run_external ()
{
	local OLDPS4="${PS4:-}"
	local extra_setup=":"

	_spec_setup_debugging
	set +e
	export PS4 spec_file

	"${spec_shell}" <<-EXTERNAL 2>> debug 1> result
		$extra_setup
		set -x
		test 'last_command_success=0' = "last_command_success=${result_code}"
		${instructions} 2>&1
	EXTERNAL

	result_code="$?"
	set +x
	set -e
	PS4="${OLDPS4}"
	echo "$result_code"
}

_spec_setup_debugging ()
{
	echo "Trace	File:Line	Statement" > debug
	if test -n "${KSH_VERSION:-}" &&
	   test -z "${KSH_VERSION##*Version AJM*}"
	then
		PS4='*	${spec_file:-$(basename ${.sh.file})}:$((${LINENO:-} - 3))	'
	elif test -n "${BASH_VERSION:-}"
	then
		PS4='*	${spec_file:-${BASH_SOURCE:-[unknown]}}:$((${LINENO:-} - 3))	'
	elif test -n "${ZSH_VERSION-}"
	then
		extra_setup="setopt PROMPT_SUBST"
		PS4='*	${spec_file:-%x}:$((${LINENO:-} - 3))	'
	else
		PS4='*	[unknown]:${LINENO:-}?	'
	fi
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
		echo
		echo "not ok	${line_report}"
		cat debug | sed 's/.*/# &/'
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

