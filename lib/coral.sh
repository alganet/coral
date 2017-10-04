##
 # coral.sh
 ##

require 'require.sh'
require 'spec.sh'
require 'assemble.sh'

coral ()
{
	local require_path="${require_path:-}:."
	local target="${1:-}"
	local target_name="${target%*.sh}"
	shift

	if test -f "${target}" &&
	   test "${target_name}.sh" = "${target}"
	then
		require "${target}"
		"${target_name}" "${@:-}"
	else
		require "${target}.sh"
		"${target}" "${@:-}"
	fi
}
