require 'tempdir.sh'
require 'pipe.sh'

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

	pipe cat \
	  -- cat \
	  -- cat "${target}" \
	  -- spec_parse "$(tempdir 'spec')"
}

spec_parse ()
{
	local spec_directory="${1}"
	local line=
	local open_fence=
	local possible_fence=
	local line_number=1

	while read -r line
	do
		possible_fence="${line#*~~~}"

		if test -z "${open_fence}"
		then
			if test "${line}" = "~~~${possible_fence}"
			then
				open_fence="${possible_fence}"
				_spec_fence_open ${open_fence}
			else
				_spec_text_line ${open_fence}
			fi
		else
			if test "${line}" = "~~~${possible_fence}"
			then
				_spec_fence_close ${open_fence}
				open_fence=
			else
				_spec_fence_line ${open_fence}
			fi
		fi

		line_number=$((line_number + 1))
	done
}

_spec_fence_open ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "file" = "${key}"
	then
		printf '' > "${spec_directory}/${value}"
	elif test "terminal" = "${language}"
	then
		printf '' > "${spec_directory}/terminal"
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
	elif test "terminal" = "${language}"
	then
		echo "$line" >> "${spec_directory}/terminal"
	fi
}

_spec_fence_close ()
{
	local language="${1:-}"
	local key="${2:-}"
	local value="${3:-}"

	if test "terminal" = "${language}"
	then
		_spec_run_terminal
	fi
}

_spec_run_terminal ()
{
	local previous="${PWD}"
	local message=
	local instructions=
	local result=true
	local result_code=0
	local expectation=
	local test_number=0

	echo "\$ test \$? = 0" >> "${spec_directory}/terminal"

	cd "${spec_directory}"

	while read -r message
	do
		if test "\$ ${message#*\$ }" = "${message}"
		then
			_spec_report_single_result

			set +e
			result="$(eval "
				test "${result_code}" = 0
				${instructions}
			")"
			result_code="$?"
			set -e

			expectation=
		else
			_spec_collect_expectation
		fi
	done < "terminal"

	cd "${previous}"
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
	if test "${expectation}" = "${result}"
	then
		echo "ok	${test_number}	${instructions}"
		instructions=
	elif test ! -z "${instructions}"
	then
		echo "not ok	${test_number}	${instructions}"
	fi

	instructions="${message#*\$ }"
	test_number=$((test_number + 1))
}

_spec_text_line ()
{
	:
}

