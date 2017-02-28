require ()
{
	local previous="${dependency:-require}"
	local dependency="${1}"
	local require_ext="${require_ext:-.sh}"
	shift

	require_loaded="${require_loaded:- }"

	if require_is_loaded "${dependency}" "${previous}" "${@:-}"
	then
		return 0
	fi

	require_source "${dependency}" || exit 1
}

require_source ()
{
	local dependency="${1}"
	local location="$(
		${require_on_search:-require_on_search} "${dependency}"
	)"

	test -f "${location}" || exit 69

	require_loaded="${require_loaded:- }${dependency} "

	${require_on_include:-require_on_include} "${location}" || exit 1
}

require_is_loaded ()
{
	dependency="${1}"
	previous="${2}"
	require_loaded="${require_loaded:- }"

	${require_on_request:-require_on_request} "${@:-}"
}

require_on_search () 
{
	require_path "${1}${require_ext}"
}

require_on_include () 
{
	local ext_file="${1}"; set --; . "${ext_file}"
}

require_on_request () 
{
	local is_ext="${dependency%${require_ext}}"

	if test "${is_ext}${require_ext}" = "${dependency}"
	then
		dependency="${is_ext}"
	fi

	if test "${require_loaded#* ${dependency} *}" = "${require_loaded}"
	then
		return 1
	fi
}

require_path ()
{
	local solved
	local IFS=':'
	local require_path=${2:-.\:${require_path:-}}

	for solved in ${require_path}
	do
		if test -f "${solved}/${1}"
		then
			printf %s "${solved}/${1}"
			return
		fi
	done
}
