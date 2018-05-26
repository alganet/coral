##
 # module_assemble.sh - bundles modules into standalone executables
 ##

require 'require.sh'
require 'script/entrypoint'
require 'script/support'
require 'fs/basename.sh'
require 'fs/tempdir.sh'
require 'fs/lines.sh'

module_assemble ()
{
	local assemble_input
	local assemble_output
	local assemble_dir
	export require_on_include
	export require_on_request
	export require_loaded

	assemble_input="${1:-}"
	assemble_output="${2:--}"
	require_on_include='module_assemble_on_include'
	require_on_request='module_assemble_on_request'
	require_loaded=' '
	assemble_dir="$(fs_tempdir 'module_assemble')"

	trap 'module_assemble_exit' 2

	printf '' > "${assemble_dir}/sources"
	module_assemble_contents "${assemble_input}" > "${assemble_dir}/output"

	if test "-" = "${assemble_output}"
	then
		fs_lines "${assemble_dir}/output"
	else
		cp "${assemble_dir}/output" "${assemble_output}"
	fi

	module_assemble_clean
}

module_assemble_clean ()
{
	rm -Rf "${assemble_dir}"
	return 0
}

module_assemble_exit ()
{
	rm -Rf "${assemble_dir}"
	exit 1
}

module_assemble_contents ()
{
	local input
	local input_file

	input="${1:-}"
	input_file="$(printf '%s\n' "${input}" | sed 's|_|/|g').sh"

	require_source 'script/support'
	printf '%s\n' "entrypoint='${input}'"
	module_assemble_dependencies "${input_file}"
	require_source 'script/entrypoint'
}

module_assemble_dependencies ()
{
	local input_file
	local require_sources

	input_file="${1:-}"

	printf '' > "${assemble_dir}/required_modules"
	printf '' > "${assemble_dir}/required_calls"
	printf '%s\n' 'require () ( : )' > "${assemble_dir}/require"
	require "${input_file}"

	require_sources="$(fs_lines "${assemble_dir}/sources")"

	if test -n "${require_sources}"
	then
		require_source 'fs/lines.sh' >> "${assemble_dir}/required_modules"
		fs_lines <<-SOURCES_SNIPPET >> "${assemble_dir}/required_modules"
			require_source ()
			{
			    if test -z "\${1:-}"
			    then
			        return
			    ${require_sources}
			    else
			        fs_lines "\$(require_path "\${1}")"
			    fi
			}
		SOURCES_SNIPPET
	fi

	printf '%s\n' "require_loaded='${require_loaded}'"
	printf '%s\n' "require_path=\"${assemble_path:-${require_path:-}}\""

	if require_is_loaded "require.sh" ""
	then
		printf '%s\n' "eval \"\$(require_source 'require.sh')\"" >> "${assemble_dir}/required_calls"
	fi

	fs_lines "${assemble_dir}/require"
	fs_lines "${assemble_dir}/required_modules"
	fs_lines "${assemble_dir}/required_calls"
}


module_assemble_on_include ()
{
	local script_target
	local script_target_name
	local assemble_dependency
	local contents

	script_target="${1}"
	assemble_dependency="${2:-}"

	script_target_name="$(fs_basename "${script_target}")"
	#contents="$(fs_lines "${script_target}")"

	test "${script_target_name%*.sh}.sh" = "${script_target_name}" || return 0

	if test "${assemble_dependency}" != "require.sh" &&
	   test "${assemble_dependency}" != "fs/lines.sh"
	then
		#printf '%s\n' "${contents}" >> "${assemble_dir}/required_modules"
		printf '%s\n' "eval \"\$(require_source '${assemble_dependency}')\"" >> "${assemble_dir}/required_calls"
		require_on_include "${@:-}"
	fi
}


module_assemble_on_request ()
{
	local assemble_dependency
	local remaining_params

	assemble_dependency="${1}"
	shift
	remaining_params="${*:-}"

	if true
	then
		fs_lines <<-SOURCES_SNIPPET >> "${assemble_dir}/sources"
			    elif test "\${1}" = "${assemble_dependency}"
			    then
			        fs_lines <<-'FILESOURCE_SNIPPET'
						$(
							require_source "${assemble_dependency}" |
							sed 's/^./			&/';
							printf \\t\\t%s 'FILESOURCE_SNIPPET'
						)
		SOURCES_SNIPPET
	fi

	require_on_request "${assemble_dependency}" "${@:-}"
}
