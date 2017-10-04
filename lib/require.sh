##
 # require.sh — a portable shell script file loader
 ##

require ()
{
	require_on_include="${require_on_include:-require_on_include}"
	require_on_request="${require_on_request:-require_on_request}"
	require_on_search="${require_on_search:-require_on_search}"

	local previous="${dependency:-require}"
	local dependency="${1}"
	shift

	require_loaded="${require_loaded:- }"

	if require_is_loaded "${dependency}" "${previous}" "${@:-}"
	then
		return 0
	fi

	if ! _require_source "${dependency}"
	then
		echo "Could not find dependency '${dependency}'"
		exit $?
	fi
}

require_on_include ()
{
	local required_file="${1}"
	set --
	. "${required_file}"
}

require_on_request ()
{
	if test "${require_loaded#* ${dependency} *}" = "${require_loaded}"
	then
		return 1
	fi
}

require_on_search ()
{
	require_path "${1}"
}

require_path ()
{
	local solved
	local require_path="${2:-.\:${require_path:-}}"
	local IFS=':'

	for solved in ${require_path}
	do
		if test -f "${solved}/${1}"
		then
			printf %s "${solved}/${1}"
			return
		fi
	done
}

require_is_loaded ()
{
	dependency="${1}"
	previous="${2}"
	require_loaded="${require_loaded:- }"

	${require_on_request} "${@:-}"
}

_require_source ()
{
	local dependency="${1}"
	local location="$(${require_on_search} "${dependency}")"

	test -f "${location}" || return 69

	require_loaded="${require_loaded:- }${dependency} "

	${require_on_include} "${location}" || return 1
}
