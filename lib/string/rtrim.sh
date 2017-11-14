string_rtrim ()
{
	while test "${2}" = "${2%${1}}${1}"
	do
		set -- "${1}" "${2%${1}}"
	done

	echo "${2}"
}
