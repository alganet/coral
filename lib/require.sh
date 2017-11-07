##
 # require.sh - a portable shell script file loader
 ##

require ()
{
	local suffix=".sh"
	local previous="${dependency:-require}"
	local dependency="${1}"
	shift

	require_loaded="${require_loaded:- }"

	if require_is_loaded "${dependency}" "${previous}" "${@:-}"
	then
		return 0
	fi

	if ! require_include "${dependency}" "${@:-}"
	then
		echo "Could not find dependency '${dependency}'"
		exit $?
	fi
}

require_on_include ()
{
	local required_file="${1}"

	test "${dependency%*${suffix}}${suffix}" = "${dependency}" || return 0

	set --
	. "${required_file}"
}

require_on_request ()
{
	local dependency="${1}"

	if test "--${dependency#*--}" = "${dependency}"
	then
		return 0
	fi

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
	local target_path="${2:-${require_path:-}}"
	local IFS=':'

	for solved in ${target_path}
	do
		if test -f "${solved}/${1}"
		then
			printf %s "${solved}/${1}"
			return
		fi
	done
}

require_include ()
{
	local dependency="${1}"
	shift
	local location="$(
		${require_on_search:-require_on_search} "${dependency}" "${@:-}"
	)"

	test -f "${location}" || return 69

	require_loaded="${require_loaded:- }${dependency} "

	${require_on_include:-require_on_include} \
		"${location}" "${dependency}" "${@:-}" ||
			return 1
}

require_is_loaded ()
{
	dependency="${1}"
	previous="${2}"
	require_loaded="${require_loaded:- }"

	${require_on_request:-require_on_request} "${@:-}"
}

require_source ()
{
	cat "$(require_path "${1}")"
}
