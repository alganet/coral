##
 # assemble.sh
 ##

require 'require.sh' --assemble-source
require 'module/entrypoint' --assemble-source
require 'module/support' --assemble-source
require 'math/random.sh'
require 'fs/tempdir.sh'

assemble ()
{
	local assemble_key="$(math_random)"
	local input="${1:-}"
	local output="${2:--}"
	local assemble_dir="$(fs_tempdir 'assemble')"

	printf '' > "${assemble_dir}/sources"
	assemble_contents "${input}" > "${assemble_dir}/output"

	if test "-" = "${output}"
	then
		cat "${assemble_dir}/output"
	else
		chmod +x "${assemble_dir}/output"
		cp "${assemble_dir}/output" "${output}"
	fi
}

assemble_contents ()
{
	local input="${1:-}"
	local input_file="$(echo "${input}" | tr '_' '/').sh"
	local input_contents=''
	local require_loaded=' '

	echo "#!/usr/bin/env sh"

	echo "# --- ${assemble_key} --- file:module/support"
	require_source 'module/support'

	echo "# --- ${assemble_key} --- env:entrypoint"
	echo "entrypoint='${input}'"

	assemble_dependencies "${input_file}"

	echo "# --- ${assemble_key} --- file:module/entrypoint"
	require_source 'module/entrypoint'
}

assemble_dependencies ()
{
	local require_on_include='assemble_on_include'
	local require_on_request='assemble_on_request'
	local input_file="${1:-}"
	local require_sources=

	require "${input_file}" > "${assemble_dir}/required_modules"

	if require_is_loaded "require.sh" ""
	then
		echo "# --- ${assemble_key} --- env:require_loaded"
		echo "require_loaded='${require_loaded}'"
		echo "# --- ${assemble_key} --- env:require_path"
		echo "require_path='${assemble_path:-${require_path}}'"
		echo "# --- ${assemble_key} --- file:require.sh"
		require_source 'require.sh'
	else
		echo "# --- ${assemble_key} --- func:require"
		echo 'require () ( : )'
	fi

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
	cat "${assemble_dir}/required_modules"
}


assemble_on_include ()
{
	local target="${1}"
	local target_name="$(basename ${target})"
	local dependency="${2:-}"
	shift 2
	local contents

	contents="$(cat "${target}")"

	test "${target_name%*.sh}.sh" = "${target_name}" || return 0

	require_on_include "${target}"
	echo "# --- ${assemble_key} --- file:${target}"

	if test "${#}" -gt 0 && test "${*#*--assemble-source*}" != "${*:-}"
	then
		echo "eval \"\$(require_source ${dependency})\""
	else
		printf %s\\n "${contents}"
	fi
}


assemble_on_request ()
{
	local dependency="${1}"
	local previous="${2}"
	shift 2

	if test "${#}" -gt 0 && test "${*#*--assemble-source*}" != "${*:-}"
	then
		cat <<-SOURCES_SNIPPET >> "${assemble_dir}/sources"
			    elif test "\${1}" = "${dependency}"
			    then
			        cat <<'FILESOURCE_SNIPPET'
						$(require_source "${dependency}")
					FILESOURCE_SNIPPET
		SOURCES_SNIPPET
	fi

	require_on_request "${target}" "${@:-}"
}
