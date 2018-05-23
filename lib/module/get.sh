##
 # module_get.sh - Manages dependency modules
 ##

require 'require.sh'
require 'net/fetch.sh'

module_get ()
{
	local repo
	local module_get_channel
	export require_on_search
	export require_on_request
	export require_on_include
	local target
	local target_file

	repo='https://raw.githubusercontent.com/alganet/coral/master/lib'
	module_get_channel="${module_get_channel:-${repo}}"
	require_on_search='module_get_on_search'
	require_on_request='module_get_on_request'
	require_on_include='module_get_on_include'
	target="${1:-}"
	shift

	target_file="$(echo "${target}" | sed 's|_|/|g').sh"

	require "${target_file}"

	"${target}" "${@:-}"
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
	local vendor
	local found

	vendor="${HOME}/.coral"
	found="$(require_on_search "${@:-}")"

	if test -z "${found}"
	then
		net_fetch "${module_get_channel}/${1}" "${vendor}/${1}" || return
		echo "${vendor}/${1}"
		return
	fi

	echo "${found}"
}
