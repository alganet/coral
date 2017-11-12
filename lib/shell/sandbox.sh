##
 # shell_sandbox.sh - runs shell code controlling variable input/output
 ##

require 'shell/vars.sh' --source
require 'math/random.sh'

shell_sandbox ()
{
	local sandbox_file="${1:-./.shell_sandbox}"
	local sandbox_instructions="${2:-:}"
	local shell_sandbox_previous_code="${shell_sandbox_previous_code:-0}"
	local return_code=0
	local shell_sandbox_shell="${shell_sandbox_shell:-sh}"
	local signature

	signature="$(math_random)"

	test -f "${sandbox_file}" || printf '' > "${sandbox_file}" || return 1

	${shell_sandbox_shell} <<-EXTERNAL && return_code=$? || return_code=$?
		$(require_source 'shell/vars.sh')
		. "${sandbox_file}"

		PATH="\${PATH}:."
		SHELL="${shell_sandbox_shell}"
		TERM=

		${shell_sandbox_setup:-}

		_sandbox_${signature} () ( return "${shell_sandbox_previous_code}" )

		set | shell_vars > "${sandbox_file}${signature}.prev"

		test '0' = "${shell_sandbox_previous_code}" || _sandbox_${signature}
		${sandbox_instructions}
		external_code=\$?

		set | shell_vars > "${sandbox_file}${signature}.next"

		exit \${external_code}
	EXTERNAL

	comm -3 -1 \
		"${sandbox_file}${signature}.prev" \
		"${sandbox_file}${signature}.next" 2>/dev/null |
		sed '/^external_code/d' >> "${sandbox_file}"

	rm "${sandbox_file}${signature}.next" "${sandbox_file}${signature}.prev"

	return ${return_code}
}
