net_fetch ()
{
	local net_fetch_command

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
		${net_fetch_command} "${1}" 2>/dev/null  > "${2}" || return 1
		return 0
	fi

	${net_fetch_command} "${1}" 2>/dev/null
}
