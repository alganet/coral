require 'assert'
require 'tempdir'

task_failed ()
{
	task_pass="not ok"
}

task_assert ()
{
	local input="${1}"
	shift

	assert_matches ()
	{
		case "${2}" in
			example )
				test "${task_expected}" = "${input}"
				return $?
				;;
			anything )
				return 0
				;;
			* )
				;;
		esac
	}

	local pass="ok"
	local piece

	assert "${input}" "${@:-}" || pass="not ok"

	printf '%s\t%s\n' "${pass}" "Assert: ${*:-}" &&
	
	printf %s "${input}" | while read -r piece
	do
		printf "	# %s\n" "${piece}"
	done
}


task_evaluate ()
{
	if test ! -z "${task_command}"
	then
		cd "${task_workplace}"
		set +e
		eval "${task_command}" 1> "${task_dir}/output" 2>logs
		task_code=$?
		set -e
		task_output="$(cat "${task_dir}/output")"
		cd "${task_runtime_dir}"
	fi
}

task_run ()
{
	local newline="${newline:-"$(printf '\n')"}"
	local task_prefix="${1:-_}"
	local task_name="${2:-}"
	local task_dir="${task_dir:-$(tempdir task)}"
	local task_runtime_dir="${task_runtime_dir:-$(pwd)}"
	local task_workplace="${task_workplace:-}"
	local task_checked=''
	local task_expect_code=''
	local task_command=''
	local task_output=''
	local task_expected=''
	local task_pass="ok"

	if test -z "${task_workplace:-}"
	then
		local task_workplace="${task_dir}/workplace"
		mkdir -p "${task_workplace}"
	fi

	_check ()
	{
		task_checked='yes'
		task_evaluate
		task_command=

		task_assert "${task_output}" ${1:-} || 
			task_failed "${2}"
	}

	_return ()
	{
		task_expect_code="${1}"
		task_evaluate
		task_command=

		test "${1}" = "${task_code}" || 
			task_failed "${2}"
	}


	_nest ()
	{
		task_run "${task_prefix}" "${1}"

		if test $? != 0
		then
			task_failed
			return 1
		fi
	}

	_blank ()
	{
		:
	}

	_expect ()
	{
		if test -z "${task_expected}"
		then
			task_expected="$(printf '%s\n' "${*:-}")"
		else
			task_expected="$(
				printf '%s\n' "${task_expected}" "${*:-}"
			)"
		fi
	}

	_file ()
	{
		local file_location="${task_workplace}/${1}"

		printf '%s\n' "${task_expected}" > "${file_location}"
	}

	_done ()
	{
		task_evaluate

		if test ! -z "${task_command}"
		then
			if test -z "${task_checked}" &&
			   test ! -z "${task_expected}"
			then
				task_assert "${task_output}" \
					matches example || 
						task_failed "a"
			fi

			if test -z "${task_expect_code}"
			then
				test "0" = "${task_code}" || 
					task_failed "b"
			fi
		fi

 		printf '%s\t%s\n' \
 			"${task_pass}" \
 			"${task_command:+\$ }${task_command:-:${task_name}}"

	 	test "${task_pass}" = "ok"
	}

	_link ()
	{
		:
	}

	_text ()
	{
		:
	}

	_call ()
	{
		task_evaluate
		task_command="${1}"
	}

	"${task_prefix}${task_name}"
}
	
