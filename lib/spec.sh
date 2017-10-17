require 'fs/tempdir.sh'
require 'pipe.sh'

spec ()
{
	local spec_shell="${spec_shell:-sh}"
	local test_number=0
	local fail_number=0
	local test_result=0
	local oldifs="${IFS}"
	local target_files="${*:-}"
	local tempdir=

	echo "# using	'${spec_shell:-sh}'"

	if test -z "${target_files}"
	then
		echo "# "
		echo "# FAILURE (no .md files found)"
		test_result=1
		return
	fi

	target_files="$(printf %s\\n ${target_files} | sort)"

	tempdir="$(fs_tempdir 'spec')"

	echo "# "

	cp -R "${PWD}" "${tempdir}/pwd"

	for target_file in ${target_files}
	do
		if test ! -f "${target_file}"
		then
			continue
		fi
		echo "# file	'${target_file}'"
		mkdir -p "${tempdir}/${target_file}.workspace"
		cp -R "${tempdir}/pwd/." "${tempdir}/${target_file}.workspace"
		spec_parse "${tempdir}/${target_file}.workspace" "${target_file}"
	done

	if test "${fail_number}" -gt 0
	then
		echo "# FAILURE (${fail_number} of ${test_number} assertions failed)"
		echo "1..${test_number}"
		test_result=1
	elif test "${test_number}" -gt 0
	then
		echo "# SUCCESS"
		echo "1..${test_number}"
	else
		echo "# FAILURE (no tests found)"
		test_result=1
	fi

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

	mkdir -p "${spec_directory}/.spec"

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
	local file_path=''

	if test "file" = "${key}"
	then
		file_path="${spec_directory}/${value}"
		if test "$(basename "${file_path}")" != "${file_path}"
		then
			mkdir -p "$(dirname "${file_path}")"
		fi
		printf '' > "${file_path}"
	elif test "console" = "${language}" &&
		 test ! -z "${key}"
	then
		printf '' > "${spec_directory}/.spec/console"
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		printf '' > "${spec_directory}/.spec/setup"
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
	elif test "console" = "${language}" &&
		 test ! -z "${key}"
	then
		echo "$line" >> "${spec_directory}/.spec/console"
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		echo "$line" >> "${spec_directory}/.spec/setup"
	fi
}

_spec_fence_close ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "console" = "${language}" &&
	   test "test" = "${key}"
	then
		_spec_run_console _spec_report_single_result
	elif test "console" = "${language}" &&
	     test "task" = "${key}"
	then
		_spec_run_console _spec_report_code_result
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		_spec_collect_setup
	fi
}

_spec_collect_setup ()
{
	setup="$(cat "${spec_directory}/.spec/setup")"
}

_spec_run_console ()
{
	local assertion="${1:-_spec_report_single_result}"
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
	printf '' > "${spec_directory}/.spec/varset"
	printf '' > "${spec_directory}/.spec/varprev"
	printf '' > "${spec_directory}/.spec/varnext"

	IFS=''
	while read -r message
	do
		IFS="${oldifs}"
		if test "\$ # ${message#*\$ # }" = "${message}"
		then
			_spec_report_comment
		elif test "\$ ${message#*\$ }" = "${message}"
		then
			${assertion}
			last_command_line="${message_line}"
			instructions="${message#*\$ }"
			test_number=$((test_number + 1))
			set +e
			pipe _spec_run_external --\
			     tee "${spec_directory}/.spec/result" --\
			     _spec_report_progress 2>&1
			result_code="${pipe_status_1}"
			set -e
			result="$(cat "${spec_directory}/.spec/result" | _spec_import_result)"

			expectation=
		else
			_spec_collect_expectation
		fi
		message_line=$((message_line + 1))
		IFS=''
	done < "${spec_directory}/.spec/console"
	IFS="${oldifs}"

	${assertion}
	instructions="${message#*\$ }"

	cd "${previous_dir}"
}

_spec_report_progress ()
{
	if test -z "${TERM:-}"
	then
		cat 1>/dev/null
		return
	fi

	set --
	local progress_line=
	local char="."
	local tput_el="$(tput 'el' 2>/dev/null || :)"
	local tput_el1="$(tput 'el1' 2>/dev/null || :)"
	local tput_dim="$(tput 'dim' 2>/dev/null || :)"
	local tput_sgr0="$(tput 'sgr0' 2>/dev/null || :)"
	local prefix="${tput_el}${tput_el1}${tput_dim}"

	printf %s\\r \
		"${prefix}███████ ${test_number} - Working...${tput_sgr0}" 2>&1

	while read -r progress_line
	do
		progress_line="$(
			printf %s "${progress_line}" |
			sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
		)"
		if test "$#" = 0
		then
			set -- " ██████" "█ █████" "██ ████" "███ ███" "████ ██" "█████ █"
		fi
		printf %s\\r \
			"${prefix}${1} ${test_number} - ${progress_line}${tput_sgr0}" 2>&1
		shift
	done

	printf \\r%s\\r "${tput_sgr0}${tput_el}${tput_el1}"  2>&1
}

_spec_import_result ()
{
	sed 's/.*/# - &$/'
}

_spec_run_external ()
{
	${spec_shell:-sh} <<-EXTERNAL 2>&1
		. "${spec_directory}/.spec/varset"
		PATH="\${PATH}:."
		SHELL="${spec_shell}"
		TERM=
		${setup}
		_spec_set () ( cat )
		_spec_return () ( return "${result_code}" )
		(set | _spec_set | sort) > "${spec_directory}/.spec/varprev"
		test '0' = "${result_code}" || _spec_return
		${instructions}
		external_code=\$?
		(set | _spec_set | sort) > "${spec_directory}/.spec/varnext"
		comm -3 -1 "${spec_directory}/.spec/varprev" "${spec_directory}/.spec/varnext" | sed '/^LINENO/d' >> "${spec_directory}/.spec/varset"
		exit \${external_code}
	EXTERNAL
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
		echo "${result}" | sed 's/# - \([^$]*\)\$/#	\1/'
		echo "# Expected"
		echo "${expectation}" | sed 's/# - \([^$]*\)\$/#	\1/'
		echo
	fi
}

_spec_report_code_result ()
{
	local line_report="${test_number} - ${instructions}"

	if test -z "${instructions}"
	then
		return
	fi

	if test '0' = "${result_code}"
	then
		echo "ok	${line_report}"
		instructions=
	else
		fail_number=$((fail_number + 1))
		error_line=$((${line_last_open_fence} + ${last_command_line:-}))
		echo
		echo "not ok	${line_report}"
		echo "# Failure on ${target_file} line ${error_line}"
		echo "# Output"
		echo "${result}" | sed 's/# - \([^$]*\)\$/#	\1/'
		echo "# Exit Code: ${result_code}"
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

