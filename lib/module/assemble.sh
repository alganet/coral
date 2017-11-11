##
 # module_assemble.sh - bundles modules into standalone executables
 ##

require 'require.sh'        --source
require 'script/entrypoint' --source
require 'script/support'    --source
require 'fs/tempdir.sh'
require 'math/random.sh'

module_assemble ()
{
	local assemble_key="$(math_random)"
	local assemble_input="${1:-}"
	local assemble_output="${2:--}"
	local assemble_dir="$(fs_tempdir 'module_assemble')"
	local require_on_include='module_assemble_on_include'
	local require_on_request='module_assemble_on_request'
	local require_loaded=' '

	trap 'module_assemble_clean' 2

	printf '' > "${assemble_dir}/sources"
	module_assemble_contents "${assemble_input}" > "${assemble_dir}/output"

	if test "-" = "${assemble_output}"
	then
		cat "${assemble_dir}/output"
	else
		chmod +x "${assemble_dir}/output"
		cp "${assemble_dir}/output" "${assemble_output}"
	fi

	module_assemble_clean return 0
}

module_assemble_clean ()
{
	rm -Rf "${assemble_dir}"
	${@:-exit 1}
}

module_assemble_contents ()
{
	local input="${1:-}"
	local input_file="$(echo "${assemble_input}" | tr '_' '/').sh"
	local input_contents=''

	require_source 'script/support'
	echo "entrypoint='${assemble_input}'"
	module_assemble_dependencies "${input_file}"
	require_source 'script/entrypoint'
}

module_assemble_dependencies ()
{
	local input_file="${1:-}"
	local require_sources=
	local require_is_sourced=0

	printf '' > "${assemble_dir}/required_modules"
	echo 'require () ( : )' > "${assemble_dir}/require"
	require "${input_file}"

	require_sources="$(cat "${assemble_dir}/sources")"

	if test -n "${require_sources}"
	then
		cat <<-SOURCES_SNIPPET
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

	cat "${assemble_dir}/require"
	cat "${assemble_dir}/required_modules"
}


module_assemble_on_include ()
{
	local script_target="${1}"
	local script_target_name="$(basename ${script_target})"
	local assemble_dependency="${2:-}"
	local contents

	contents="$(cat "${script_target}")"

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
		cat <<-SOURCES_SNIPPET >> "${assemble_dir}/sources"
			    elif test "\${1}" = "${assemble_dependency}"
			    then
			        cat <<'FILESOURCE_SNIPPET'
						$(require_source "${assemble_dependency}")
					FILESOURCE_SNIPPET
		SOURCES_SNIPPET
	fi

	require_on_request "${assemble_dependency}" "${@:-}"
}
