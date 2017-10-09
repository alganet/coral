##
 # coral.sh
 ##

require 'require.sh'
require 'spec.sh'
require 'assemble.sh'

coral ()
{
	local require_path="${require_path:-}${require_path:+:.}"
	local target="${1:-}"
	local target_path="${target%*.sh}"
	local target_name="$(basename "${target_path%*.sh}")"
	shift

	if test "${target_path}" != "${target_name}"
	then
		target_name=":"
	fi

	if test -f "${target}" &&
	   test "${target_name}.sh" = "${target}"
	then
		require "${target}"
		"${target_name}" "${@:-}"
	else
		require "${target}.sh"
		"${target_name}" "${@:-}"
	fi
}
