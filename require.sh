# require.sh - A portable shell script module loader.
#
# - Supports circular dependencies.
# - Supports multiple loading paths.
# - Provides hooks to notify external code of loading events.
#

# Hook: Function called when a file source is included
require_on_include="${require_on_include:-require_on_include}"
# Hook: Function called when a source file is requested
require_on_request="${require_on_request:-require_on_request}"
# Hook: Function called when a source file is searched on the path
require_on_search="${require_on_search:-require_on_search}"

# Loads a module, skips if it is already loaded.
#
# Usage: `require DEPENDENCY_NAME`
#
require ()
{
	local previous="${dependency:-require}"
	local dependency="${1}"
	shift

	require_loaded="${require_loaded:- }"

	if _require_is_on_load_list "${dependency}" "${previous}" "${@:-}"
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
	local required_file="${1}"; set --; . "${required_file}"
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

# Solves a path
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

# Checks if a module is loaded in the current list.
_require_is_on_load_list ()
{
	dependency="${1}"
	previous="${2}"
	require_loaded="${require_loaded:- }"

	${require_on_request} "${@:-}"
}

# Sources the module file
_require_source ()
{
	local dependency="${1}"
	local location="$(${require_on_search} "${dependency}")"

	test -f "${location}" || return 69

	require_loaded="${require_loaded:- }${dependency} "

	${require_on_include} "${location}" || return 1
}
