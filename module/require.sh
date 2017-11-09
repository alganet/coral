##
 # require.sh - a portable shell script file loader
 ##

module_require ()
{
	local suffix=".sh"
	local previous="${dependency:-require}"
	local dependency="${1}"
	shift

	module_require_loaded="${module_require_loaded:- }"

	if module_require_is_loaded "${dependency}" "${previous}" "${@:-}"
	then
		return 0
	fi

	if ! module_require_include "${dependency}" "${@:-}"
	then
		echo "Could not find dependency '${dependency}'"
		exit $?
	fi
}

module_require_on_include ()
{
	local required_file="${1}"

	test "${dependency%*${suffix}}${suffix}" = "${dependency}" || return 0

	set --
	. "${required_file}"
}

module_require_on_request ()
{
	local dependency="${1}"

	if test "--${dependency#*--}" = "${dependency}"
	then
		return 0
	fi

	if test "${module_require_loaded#* ${dependency} *}" = \
			"${module_require_loaded}"
	then
		return 1
	fi
}

module_require_on_search ()
{
	module_require_path "${1}"
}

module_require_path ()
{
	local solved
	local target_path="${2:-${module_require_path:-}}"
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

module_require_include ()
{
	local dependency="${1}"
	shift
	local location="$(
		${module_require_on_search:-module_require_on_search} \
			"${dependency}" "${@:-}"
	)"

	test -f "${location}" || return 69

	module_require_loaded="${module_require_loaded:- }${dependency} "

	${module_require_on_include:-module_require_on_include} \
		"${location}" "${dependency}" "${@:-}" ||
			return 1
}

module_require_is_loaded ()
{
	dependency="${1}"
	previous="${2}"
	module_require_loaded="${module_require_loaded:- }"

	${module_require_on_request:-module_require_on_request} "${@:-}"
}

module_require_source ()
{
	cat "$(module_require_path "${1}")"
}
