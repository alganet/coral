assert_ends_with ()
{
	local starts_with="${1%%${2}}"
	local ends_with="${1#${starts_with}}"

	test "${1}" = "${starts_with}${ends_with}"
}
assert_line_count () { :; }
assert_same_as ()
{
	test "${1}" = "${2}"
}

assert ()
{
	local input="${1}"
	local phrase=''
	shift

	while test "${#}" -gt 1
	do
		phrase="${phrase}_${1}"
		shift
	done

	assert${phrase} "${input}" "${1}"
}
