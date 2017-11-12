##
 # net_fetch.sh - obtains files from the network
 ##

require 'fs/dirname.sh'
require 'fs/tempdir.sh'

net_fetch ()
{
	local net_fetch_command
	local tempdir
	local download_dir

	if curl --help >/dev/null 2>&1
	then
		net_fetch_command='curl --fail -kL'
	elif wget --help >/dev/null 2>&1
	then
		net_fetch_command='wget -qO-'
	fi

	if test -z "${net_fetch_command:-}"
	then
		return 1
	fi

	if test -n "${2:-}"
	then
		tempdir="$(fs_tempdir 'net_fetch')"
		mkdir -p "$(fs_dirname "${tempdir}/${2}")"
		trap 'net_fetch_clear' 2

		if ${net_fetch_command} "${1}" 2>/dev/null  > "${tempdir}/${2}"
		then
			download_dir="$(fs_dirname "${2}")"
			mkdir -p "${download_dir}"
			mv "${tempdir}/${2}" "${download_dir}"
			net_fetch_clear
		fi

		return 0
	fi

	${net_fetch_command} "${1}" 2>/dev/null
}

net_fetch_clear ()
{
	rm -Rf "${tempdir}"
}
