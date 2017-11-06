##
 # assemble.sh - bundles modules into standalone executables
 ##

require 'require.sh' --assemble-source
require 'module/entrypoint' --assemble-source
require 'module/support' --assemble-source
require 'fs/tempdir.sh'
require 'math/random.sh'
require 'shell/route.sh'

assemble ()
{
	shell_route_options_only=true \
		shell_route 'assemble' "${@:-}" ||
			assemble_bundle "${@:-}"
}

assemble_option_help ()
{
	cat <<-HELPTEXT
		Usage: assemble [ARGUMENTS] MODULE OUTPUT_FILE

		Options:
		  --help     Displays this help
		  --version  Displays version information

		MODULE can be any require.sh compatible module in the current
		require_path.

		OUTPUT_FILE must be a path for the output executable file.

	HELPTEXT
}

assemble_bundle ()
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

	require_source 'module/support'
	echo "entrypoint='${input}'"
	assemble_dependencies "${input_file}"
	require_source 'module/entrypoint'
}

assemble_dependencies ()
{
	local require_on_include='assemble_on_include'
	local require_on_request='assemble_on_request'
	local input_file="${1:-}"
	local require_sources=
	local require_is_sourced=0

	printf 'require () ( : )' > "${assemble_dir}/require"
	require "${input_file}" > "${assemble_dir}/required_modules"

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
	echo "require_path='${assemble_path:-${require_path}}'"

	if require_is_loaded "require.sh" ""
	then
		require_source 'require.sh' > "${assemble_dir}/require"
	fi

	cat "${assemble_dir}/require"
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

	if test "${*#*--assemble-source*}" = "${*:-}" &&
	   test "${dependency}" != "require.sh"
	then
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

		if test "${dependency%*.sh}.sh" = "${dependency}" &&
		   test "${dependency}" != "require.sh"
		then
			echo "eval \"\$(require_source '${dependency}')\""
		fi
	fi


	require_on_request "${dependency}" "${previous}" "${@:-}"
}
