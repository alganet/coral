##
 # module_get.sh - Manages dependency modules
 ##

require 'require.sh'
require 'net/fetch.sh'

module_get ()
{
	local repo='https://raw.githubusercontent.com/alganet/coral/master'
	local module_get_channel="${module_get_channel:-${repo}}"
	export require_on_search='module_get_on_search'
	export require_on_request='module_get_on_request'
	export require_on_include='module_get_on_include'
	local target="${1:-}"
	local target_file
	shift

	target_file="$(echo "${target}" | sed 's|_|/|g').sh"


	require "${target_file}"
}

module_get_on_request ()
{
	if test "--channel" = "${1}"
	then
		module_get_channel="${3:-${repo}}"
		return 0
	fi

	require_on_request "${@:-}"
}

module_get_on_include ()
{
	module_get_channel="${repo}"
	require_on_include "${@:-}"
}

module_get_on_search ()
{
	local vendor="${HOME}/.coral"
	local found

	found="$(require_on_search "${@:-}")"

	if test -z "${found}"
	then
		net_fetch "${module_get_channel}/${1}" "${vendor}/${1}" || return
		echo "${vendor}/${1}"
		return
	fi

	echo "${found}"
}
