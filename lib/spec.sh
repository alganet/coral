require 'tempdir.sh'

spec()
{
	local target="${1:-.}"
	local spec_shell="${spec_shell:-sh}"
	local test_number=0
	local fail_number=0
	local test_result=0
	local tempdir="$(tempdir 'spec')"
	local oldifs="${IFS}"

	echo "# using	'${spec_shell}'"
	echo "# on	'${tempdir}'"
	echo "# "

	cp -R "${PWD}/." "${tempdir}"

	for target_file in $(find "${target}" -type f)
	do
		echo "# file	'${target_file}'"
		spec_parse "${tempdir}" "${target_file}"
	done

	if test "${fail_number}" -gt 0
	then
		echo "# FAILURE (${fail_number} of ${test_number} assertions failed)"
		test_result=1
	else
		echo "# SUCCESS"
	fi

	echo "1..${test_number}"

	return "${test_result}"
}

spec_parse ()
{
	local spec_directory="${1}"
	local line=
	local open_fence=
	local possible_fence=
	local line_number=1
	local line_last_open_fence=0
	local setup='true'
	local oldifs="${IFS}"

	IFS=''
	while read -r line
	do
		IFS="${oldifs}"
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
		IFS=''
	done < "${2}"
	IFS="${oldifs}"
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
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		printf '' > "${spec_directory}/setup"
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
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		echo "$line" >> "${spec_directory}/setup"
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
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		_spec_collect_setup
	fi
}

_spec_collect_setup ()
{
	setup="$(cat "${spec_directory}/setup")"
}

_spec_copy_folder ()
{
	local source_dir="${1:-.}"
	local dest_dir="${2:-.}"
	local entry=
	local relative=

	for entry in $(find "${source_dir}")
	do
		relative="${entry#*${source_dir}}"
		absolute="${source_dir}${relative}"

		if ! test -r "${relative}"
		then
			continue
		fi

		if test -d "${absolute}"
		then
			mkdir -p "${dest_dir}${relative}"
		else
			cp "${absolute}"  -- "${dest_dir}${relative}"
		fi
	done
}

_spec_run_console ()
{
	local previous_dir="${PWD}"
	local message=
	local instructions=
	local result=true
	local result_code=0
	local expectation=
	local expectation_lines=0
	local message_line=1
	local last_command_line=0
	local oldifs="${IFS}"

	cd "${spec_directory}"

	IFS=''
	while read -r message
	do
		IFS="${oldifs}"
		if test "\$ # ${message#*\$ # }" = "${message}"
		then
			_spec_report_comment
		elif test "\$ ${message#*\$ }" = "${message}"
		then
			_spec_report_single_result
			last_command_line="${message_line}"
			instructions="${message#*\$ }"
			test_number=$((test_number + 1))
			result_code=$(_spec_run_external 2>/dev/null)
			result="$(cat result | _spec_import_result)"

			expectation=
		else
			_spec_collect_expectation
		fi
		message_line=$((message_line + 1))
		IFS=''
	done < "console"
	IFS="${oldifs}"

	_spec_report_single_result
	instructions="${message#*\$ }"

	cd "${previous_dir}"
}

_spec_import_result ()
{
	sed 's/.*/# - &$/'
}

_spec_run_external ()
{
	set +e
	${spec_shell} <<-EXTERNAL > result 2>&1
		_spec_return () ( return "${result_code}" )
		${setup}
		test '0' = "${result_code}" || _spec_return
		${instructions}
	EXTERNAL
	result_code="$?"
	set -e
	echo "$result_code"
}

_spec_collect_expectation ()
{
	if test -z "${expectation}" && test -z "${message}"
	then
		expectation="# - $(printf \\n)$"
	elif test -z "${expectation}"
	then
		expectation="$(printf %s\\n "# - ${message}$")"
	else
		expectation="$(printf %s\\n "${expectation}" "# - ${message}$")"
	fi

	expectation_lines=$((expectation_lines + 1))
}

_spec_report_single_result ()
{
	local line_report="${test_number} - ${instructions}"

	if test "${expectation}" = "${result}"
	then
		echo "ok	${line_report}"
		instructions=
	elif test ! -z "${instructions}"
	then
		fail_number=$((fail_number + 1))
		error_line=$((${line_last_open_fence} + ${last_command_line:-}))
		echo
		echo "not ok	${line_report}"
		echo "# Failure on ${target_file} line ${error_line}"
		echo "# Output"
		echo "${result}" | sed 's/# - \([^$]*\)\$/#	\1 |/'
		echo "# Expected"
		echo "${expectation}" | sed 's/# - \([^$]*\)\$/#	\1 |/'
		echo
	fi
}

_spec_text_line ()
{
	:
}

_spec_report_comment ()
{
	:
}

