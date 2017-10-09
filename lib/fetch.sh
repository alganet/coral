fetch ()
{
	if curl --help >/dev/null 2>&1
	then
		curl --fail -kL "${1}" \
			2>/dev/null > "${2}" || return 1

		return 0
	elif wget --help >/dev/null 2>&1
	then
		wget -qO- "${1}" \
			2>/dev/null  > "${2}" || return 1

		return 0
	fi

	return 127
}
