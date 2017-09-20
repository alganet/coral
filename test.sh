#!/usr/bin/env sh

# Options for all shells
#
# -e: Exit if any command has an uncaught error code
# -u: Exit on any use of an undefined variable
# -f: Do not expand glob patterns
set -euf

# Mimic local variables on ksh by aliasing it to typeset
#
# This command is ignored by shells other than ksh. pdksh and mksh are also
# ignored, they support local variables.
#
if test -n "${KSH_VERSION:-}" &&
   test -z "${KSH_VERSION##*Version AJM*}"
then
	alias local=typeset
elif test -n "${BASH_VERSION:-}"
then
	set -o posix
elif test -n "${ZSH_VERSION-}"
then
	# Unset options for zsh to make it more portable
	#
	# NO_IGNORE_BRACES: Make it ignore proprietary braces syntax
	# NO_MATCH: Avoid expanding extra filename patterns
	# NO_SHWORDSPLIT: Make the word split on zsh behave like POSIX
	# BAD_PATTERN: Ignore errors for zsh-specific syntax
	#
	# This command is ignored in shells other than zsh.
	#
	unsetopt \
		NO_IGNORE_BRACES \
		NO_MATCH \
		NO_SH_WORD_SPLIT \
		BAD_PATTERN >/dev/null 2>&1 || :
fi

##
 # require.sh — a portable shell script file loader
 ##

require ()
{
	require_on_include="${require_on_include:-require_on_include}"
	require_on_request="${require_on_request:-require_on_request}"
	require_on_search="${require_on_search:-require_on_search}"

	local previous="${dependency:-require}"
	local dependency="${1}"
	shift

	require_loaded="${require_loaded:- }"

	if _require_is_on_load_list "${dependency}" "${previous}" "${@:-}"
	then
		return 0
	fi

	if ! _require_source "${dependency}"
	then
		echo "Could not find dependency '${dependency}'"
		exit $?
	fi
}

require_on_include ()
{
	local required_file="${1}"
	set --
	. "${required_file}"
}

require_on_request ()
{
	if test "${require_loaded#* ${dependency} *}" = "${require_loaded}"
	then
		return 1
	fi
}

require_on_search ()
{
	require_path "${1}"
}

require_path ()
{
	local solved
	local require_path="${2:-.\:${require_path:-}}"
	local IFS=':'

	for solved in ${require_path}
	do
		if test -f "${solved}/${1}"
		then
			printf %s "${solved}/${1}"
			return
		fi
	done
}

_require_is_on_load_list ()
{
	dependency="${1}"
	previous="${2}"
	require_loaded="${require_loaded:- }"

	${require_on_request} "${@:-}"
}

_require_source ()
{
	local dependency="${1}"
	local location="$(${require_on_search} "${dependency}")"

	test -f "${location}" || return 69

	require_loaded="${require_loaded:- }${dependency} "

	${require_on_include} "${location}" || return 1
}
entrypoint=spec
require_path=./lib
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

	cat "${target}" | spec_parse "$(tempdir 'spec')"
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
	local previous="${PWD}"
	local message=
	local instructions=
	local result=true
	local result_code=0
	local expectation=
	local test_number=0


	if test "terminal" = "${language}"
	then
		_spec_run_terminal
	fi
}

_spec_run_terminal ()
{
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

#!/usr/bin/env sh

# Run command named by the entrypoint variable or nothing (the : command)
${entrypoint:-:} "${@:-}"
