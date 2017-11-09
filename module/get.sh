##
 # module_get.sh - Manages dependency modules
 ##

require 'module/require.sh'
require 'net/fetch.sh'

module_get ()
{
	local repo='https://raw.githubusercontent.com/alganet/coral/master'
	local module_get_channel="${module_get_channel:-${repo}}"
	local module_require_on_search='module_get_on_search'
	local module_require_on_request='module_get_on_request'
	local module_require_on_include='module_get_on_include'
	local target="${1:-}"
	local target_file="$(echo "${target}" | tr '_' '/').sh"
	shift

	require "${target_file}"
}

module_get_on_request ()
{
	if test "--channel" = "${1}"
	then
		module_get_channel="${3:-${repo}}"
		return 0
	fi

	module_require_on_request "${@:-}"
}

module_get_on_include ()
{
	module_get_channel="${repo}"
	module_require_on_include "${@:-}"
}

module_get_on_search ()
{
	local vendor="${HOME}/.coral"
	local found="$(module_require_on_search "${@:-}")"

	if test -z "${found}"
	then
		net_fetch "${module_get_channel}/${1}" "${vendor}/${1}" || return
		echo "${vendor}/${1}"
		return
	fi

	echo "${found}"
}
