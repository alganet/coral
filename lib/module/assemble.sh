##
 # module_assemble.sh - bundles modules into standalone executables
 ##

require 'require.sh'        --source
require 'script/entrypoint' --source
require 'script/support'    --source
require 'fs/basename.sh'
require 'fs/tempdir.sh'
require 'fs/get.sh'

module_assemble ()
{
	local assemble_input="${1:-}"
	local assemble_output="${2:--}"
	local assemble_dir
	export require_on_include='module_assemble_on_include'
	export require_on_request='module_assemble_on_request'
	export require_loaded=' '

	assemble_dir="$(fs_tempdir 'module_assemble')"

	trap 'module_assemble_exit' 2

	> "${assemble_dir}/sources"
	module_assemble_contents "${assemble_input}" > "${assemble_dir}/output"

	if test "-" = "${assemble_output}"
	then
		fs_get "${assemble_dir}/output"
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
	local input="${1:-}"
	local input_file

	input_file="$(echo "${input}" | sed 's|_|/|g').sh"

	require_source 'script/support'
	echo "entrypoint='${input}'"
	module_assemble_dependencies "${input_file}"
	require_source 'script/entrypoint'
}

module_assemble_dependencies ()
{
	local input_file="${1:-}"
	local require_sources=

	> "${assemble_dir}/required_modules"
	echo 'require () ( : )' > "${assemble_dir}/require"
	require "${input_file}"

	require_sources="$(fs_get "${assemble_dir}/sources")"

	if test -n "${require_sources}"
	then
		if ! require_is_loaded 'fs/get.sh' ''
		then
			require_source 'fs/get.sh' >> "${assemble_dir}/required_modules"
		fi
		fs_get <<-SOURCES_SNIPPET >> "${assemble_dir}/required_modules"
			require_source ()
			{
			    if test -z "\${1:-}"
			    then
			        return
			    ${require_sources}
			    else
			        cat "\$(require_path "\${1}")"
			    fi
			}
		SOURCES_SNIPPET
	fi

	echo "require_loaded='${require_loaded}'"
	echo "require_path=\"\${assemble_path:-${require_path:-}}\""

	if require_is_loaded "require.sh" ""
	then
		require_source 'require.sh' > "${assemble_dir}/require"
	fi

	fs_get "${assemble_dir}/require"
	fs_get "${assemble_dir}/required_modules"
}


module_assemble_on_include ()
{
	local script_target="${1}"
	local script_target_name
	local assemble_dependency="${2:-}"
	local contents

	script_target_name="$(fs_basename "${script_target}")"
	contents="$(fs_get "${script_target}")"

	test "${script_target_name%*.sh}.sh" = "${script_target_name}" || return 0

	if test "${assemble_dependency}" != "require.sh"
	then
		printf %s\\n\\n "${contents}" >> "${assemble_dir}/required_modules"
		require_on_include "${@:-}"
	fi
}


module_assemble_on_request ()
{
	local assemble_dependency="${1}"
	shift
	local remaining_params="${*:-}"

	if test "${#}" -gt 0 && test "${remaining_params#*--source*}" != "${*:-}"
	then
		fs_get <<-SOURCES_SNIPPET >> "${assemble_dir}/sources"
			    elif test "\${1}" = "${assemble_dependency}"
			    then
			        fs_get <<'FILESOURCE_SNIPPET'
						$(require_source "${assemble_dependency}")
					FILESOURCE_SNIPPET
		SOURCES_SNIPPET
	fi

	require_on_request "${assemble_dependency}" "${@:-}"
}
