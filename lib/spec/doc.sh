##
 # spec_doc.sh - a literate test runner
 ##

require 'fs/basename.sh'
require 'fs/dirname.sh'
require 'fs/tempdir.sh'
require 'fs/lines.sh'
require 'shell/assertion.sh'

spec_doc ()
{
	local spec_doc_shell
	local test_number
	local fail_number
	local test_result
	local oldifs
	local spec_doc_tmp

	spec_doc_shell="${spec_doc_shell:-sh}"
	test_number=1
	fail_number=0
	test_result=0
	oldifs="${IFS}"

	trap 'spec_doc_clean' 2 >/dev/null 2>&1 || :

	printf '%s\n' "# using	'${spec_doc_shell:-sh}'"

	if test -z "${*:-}"
	then
		printf '%s\n' "# "
		printf '%s\n' "# FAILURE (no .md files found)"
		test_result=1
		return
	fi

	target_files="$(printf '%s\n' "${@:-}")"

	spec_doc_tmp="$(fs_tempdir 'spec_doc')"

	printf '%s\n' "# "

	cp -R "${PWD}" "${spec_doc_tmp}/pwd"

	for target_file in ${target_files}
	do
		if test ! -f "${target_file}"
		then
			continue
		fi
		printf '%s\n' "# file	'${target_file}'"
		mkdir -p "${spec_doc_tmp}/${target_file}.workspace"
		cp -R "${spec_doc_tmp}/pwd/." "${spec_doc_tmp}/${target_file}.workspace"
		spec_doc_parse "${spec_doc_tmp}/${target_file}.workspace" "${target_file}"
	done

	if test "${fail_number}" -gt 0
	then
		printf '%s\n' "# FAILURE (${fail_number} of ${test_number} assertions failed)"
		printf '%s\n' "1..${test_number}"
		test_result=1
	elif test "${test_number}" -gt 0
	then
		printf '%s\n' "# SUCCESS"
		printf '%s\n' "1..${test_number}"
	else
		printf '%s\n' "# FAILURE (no tests found)"
		test_result=1
	fi

	spec_doc_return "${test_result}"
}

spec_doc_return ()
{
	rm -Rf "${spec_doc_tmp}"
	return "${1:-1}"
}

spec_doc_parse ()
{
	local spec_directory
	local line
	local open_fence
	local possible_fence
	local line_number
	local line_last_open_fence
	local setup
	local oldifs

	line_last_open_fence=0
	line_number=1
	spec_directory="${1}"
	setup='true'
	oldifs="${IFS}"

	mkdir -p "${spec_directory}/.spec"

	IFS=''
	while read -r line
	do
		IFS="${oldifs}"
		possible_fence="${line#*\`\`\`}"

		if test -z "${open_fence:-}"
		then
			if test "${line}" = "\`\`\`${possible_fence}"
			then
				open_fence="${possible_fence}"
				line_last_open_fence="${line_number}"
				# Intentionally splitting arguments in variable here
				# shellcheck disable=SC2086
				spec_doc_fence_open ${open_fence}
			fi
		else
			if test "${line}" = "\`\`\`${possible_fence}"
			then
				# Intentionally splitting arguments in variable here
				# shellcheck disable=SC2086
				spec_doc_fence_close ${open_fence}
				open_fence=
			else
				# Intentionally splitting arguments in variable here
				# shellcheck disable=SC2086
				spec_doc_fence_line ${open_fence}
			fi
		fi

		line_number=$((line_number + 1))
		IFS=''
	done < "${2}"
	IFS="${oldifs}"
}

spec_doc_fence_open ()
{
	local language
	local key
	local value
	local file_path

	language="${1:-}"
	key="${2:-}"
	value="${3:-}"
	file_path=''

	if test "file" = "${key}"
	then
		file_path="${spec_directory}/${value}"
		if test "$(fs_basename "${file_path}")" != "${file_path}"
		then
			mkdir -p "$(fs_dirname "${file_path}")"
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

spec_doc_fence_line ()
{
	local language
	local key
	local value

	language="${1:-}"
	key="${2:-}"
	value="${3:-}"

	if test "file" = "${key}"
	then
		printf '%s\n' "$line" >> "${spec_directory}/${value}"
	elif test "console" = "${language}" &&
		 test ! -z "${key}"
	then
		printf '%s\n' "$line" >> "${spec_directory}/.spec/console"
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		printf '%s\n' "$line" >> "${spec_directory}/.spec/setup"
	fi
}

spec_doc_fence_close ()
{
	local language
	local key
	local value

	language="${1:-}"
	key="${2:-}"
	value="${3:-}"

	if test "console" = "${language}" &&
	   test "test" = "${key}"
	then
		spec_doc_run_console spec_doc_report_single_result
	elif test "console" = "${language}" &&
	     test "task" = "${key}"
	then
		spec_doc_run_console spec_doc_report_code_result
	elif test "setup" = "${key}" && test "${language}" != "console"
	then
		spec_doc_collect_setup
	fi
}

spec_doc_collect_setup ()
{
	setup="$(fs_lines "${spec_directory}/.spec/setup")"
}

spec_doc_run_console ()
{
	local sandbox_code

	shell_sandbox_setup="${setup:-}" \
	shell_sandbox_shell="${spec_doc_shell:-}" \
		shell_assertion \
			"${spec_directory}/.spec/console" "${spec_directory}" "${@:-}" &&
			sandbox_code=$? ||
			sandbox_code=$?
}

spec_doc_report_single_result ()
{
	local line_report

	line_report="${test_number} - ${1}"

	if test "${2}" = "${3}"
	then
		test_number=$((test_number + 1))
		printf '%s\n' "ok	${line_report}"
	elif test ! -z "${1}"
	then
		test_number=$((test_number + 1))
		fail_number=$((fail_number + 1))
		error_line="${line_last_open_fence}"
		printf '%s\n' "not ok	${line_report}"
		printf '%s\n' "# Failure on ${target_file} line ${error_line}"
		printf '%s\n' "${3}" | sed 's/# - \(.*\)/\1/' > "${spec_directory}/.assertion_output"
		printf '%s\n' "${2}" | sed 's/# - \(.*\)/\1/' > "${spec_directory}/.assertion_expectation"
		diff "${spec_directory}/.assertion_expectation" "${spec_directory}/.assertion_output"
	fi
}

spec_doc_report_code_result ()
{
	local line_report

	line_report="${test_number} - ${1}"

	if test -z "${1}"
	then
		return
	fi

	test_number=$((test_number + 1))

	if test '0' = "${sandbox_code}"
	then
		printf '%s\n' "ok	${line_report}"
	else
		fail_number=$((fail_number + 1))
		error_line="${line_last_open_fence}"
		printf '%s\n' "not ok	${line_report}"
		printf '%s\n' "# Failure on ${target_file} line ${error_line}"
		printf '%s\n' "# Output"
		printf '%s\n' "${3}" | sed 's/# - \(.*\)/#	\1/'
		printf '%s\n' "# Exit Code: ${sandbox_code}"
	fi
}
