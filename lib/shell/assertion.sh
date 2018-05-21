##
 # shell_assertion.sh - runs and verifies terminal session interactions
 ##

require 'shell/sandbox.sh'

shell_assertion ()
{
	local assertion_dir="${2:-.}"
	local assertion="${3:-_shell_assertion_report}"
	local previous_dir="${PWD}"
	local message=
	local instructions=
	local result=true
	local sandbox_code=0
	local expectation=
	local expectation_lines=0
	local message_line=1
	local oldifs="${IFS}"
	local sandbox_id

	sandbox_id="$(math_random)"

	cd "${assertion_dir}"

	IFS=''
	while read -r message
	do
		IFS="${oldifs}"
		if test "\$ ${message#*\$ }" = "${message}"
		then
			${assertion} "${instructions}" "${expectation}" "${result}"
			instructions="${message#*\$ }"
			set +e
			shell_sandbox_previous_code="${sandbox_code}" \
				shell_sandbox "${assertion_dir}/.${sandbox_id}" "${instructions}" \
				printf '' > "${assertion_dir}/.assertion_result" 2>&1
			sandbox_code="${?}"
			set -e
			result="$(
				_shell_assertion_import_result \
					< "${assertion_dir}/.assertion_result"
			)"

			expectation=
		else
			_shell_assertion_collect_expectation
		fi
		message_line=$((message_line + 1))
		IFS=''
	done < "${1}"
	IFS="${oldifs}"

	${assertion} "${instructions}" "${expectation}" "${result}"
	instructions="${message#*\$ }"

	cd "${previous_dir}"
}


_shell_assertion_import_result ()
{
	sed 's/^.*$/# - &/'
}


_shell_assertion_collect_expectation ()
{
	if test -z "${expectation}" && test -z "${message}"
	then
		expectation="# - $(printf \\n)"
	elif test -z "${expectation}"
	then
		expectation="$(printf %s\\n "# - ${message}")"
	else
		expectation="$(
			printf %s\\n "${expectation}"
			printf %s\\n "# - ${message}"
		)"
	fi

	expectation_lines=$((expectation_lines + 1))
}

_shell_assertion_report ()
{
	local line_report="${1}"

	if test "${2}" = "${3}"
	then
		echo "  $ ${line_report}"
		echo "${2}" | sed 's/# - \(.*\)/  \1/'
	elif test ! -z "${1}"
	then
		echo "  $ ${line_report}"
		echo "${3}" | sed 's/# - \(.*\)/+ \1/'
		echo "${2}" | sed 's/# - \(.*\)/- \1/'
	fi
}
