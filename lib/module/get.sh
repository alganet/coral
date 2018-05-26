##
 # module_get.sh - Manages dependency modules
 ##

require 'require.sh'
require 'net/fetch.sh'
require 'fs/tempdir.sh'

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
	module_get_folder="${module_get_folder:-$(fs_tempdir module_get)}"
	module_get_channel="${module_get_channel:-${repo}}"
	require_on_search='module_get_on_search'
	require_on_request='module_get_on_request'
	require_on_include='module_get_on_include'
	target="${1:-}"
	shift

	target_file="$(printf '%s\n' "${target}" | sed 's|_|/|g').sh"

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
	local found

	found="$(require_on_search "${@:-}")"

	if test -z "${found}"
	then
		net_fetch "${module_get_channel}/${1}" "${module_get_folder}/${1}" || return
		printf '%s\n' "${module_get_folder}/${1}"
		return
	fi

	printf '%s\n' "${found}"
}
