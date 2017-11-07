##
 # coral.sh - a shell script ecosystem
 ##

require 'require.sh'
require 'shell/route.sh'
require 'net/fetch.sh'

coral ()
{
	local repo='https://raw.githubusercontent.com/alganet/coral/master/lib'
	local coral_channel="${coral_channel:-${repo}}"

	if test -z "${1:-}"
	then
		echo "No arguments. Try ${0} --help" 1>&2
		return 1
	fi

	shell_route_options_only=true \
		shell_route 'coral' "${@:-}" ||
			coral_run "${@:-}"
}

coral_run ()
{
	local target="${1:-}"
	local target_file="$(echo "${target}" | tr '_' '/').sh"
	shift

	require "${target_file}"
	"${target}" "${@:-}"
}

coral_option_list ()
{
	local oldifs="${IFS}"
	local path_dir
	local path_name
	local shell_entry
	local shell_script

	IFS=':'
	{
		printf %s\\n 'MODULE FILE'
		for path_dir in ${require_path}
		do
			if test "${path_dir}" = '.'
			then
				path_name=""
			else
				path_name="/$(basename "${path_dir}")"
			fi

			find "$(cd "$(dirname "${path_dir}")";pwd)${path_name}" -type f |
				grep '.sh$' |
				while read shell_entry
				do
					shell_script="${shell_entry##*${path_name}}"
					shell_script="${shell_script#/}"
					shell_script="${shell_script%.sh}"

					if test -n "${shell_script}"
					then
						printf %s "${shell_script}" | tr '/' '_'
						printf %s\\n " ${shell_entry##*${PWD}/}"
					fi
				done
		done | sort | uniq
	} | column -t

	IFS="${oldifs}"
}

coral_option_get ()
{
	local require_on_search='coral_on_search'
	local require_on_request='coral_on_request'
	local require_on_include='coral_on_include'

	coral_run "${@:-}" || true
}

coral_on_request ()
{
	if test "--channel" = "${1}"
	then
		coral_channel="${3:-${repo}}"
		return 0
	fi

	require_on_request "${@:-}"
}

coral_on_include ()
{
	coral_channel="${repo}"
	require_on_include "${@:-}"
}

coral_on_search ()
{
	local vendor="${HOME}/.coral/lib"
	local found="$(require_on_search "${@:-}")"

	if test -z "${found}"
	then
		net_fetch "${coral_channel}/${1}" "${vendor}/${1}" || return
		echo "${vendor}/${1}"
		return
	fi

	echo "${found}"
}

coral_option_help ()
{
	cat <<-HELPTEXT
		Usage: coral [ARGUMENTS] [MODULE]

		Options:
		  --get       Retrieve and run modules
		  --list      List all installed modules in the current require_path.
		  --help      Displays this help
		  --version   Displays version information

		Loaded Modules:
		 ${require_loaded}

		MODULE can be any require.sh compatible module in the current
		require_path.

	HELPTEXT
}
