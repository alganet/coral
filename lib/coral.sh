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
	local target_file="$(echo "${target}" | tr '_' '/').sh"
	shift

	require "${target_file}"
	"${target}" "${@:-}"
}
