##
 # assemble.sh
 ##

require 'require.sh'
require 'require/entrypoint'
require 'require/support'
require 'fs/tempdir.sh'

assemble ()
{
	local input="${1:-}"
	local output="${2:--}"
	local assemble_dir="$(fs_tempdir 'assemble')"

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
	local input_name="$(basename "${input%*.sh}")"
	local input_file=''
	local input_contents=''
	local require_loaded=' '

	if test -f "${input}" &&
	   test "${input_name}.sh" = "$(basename "${input}")"
	then
		input_file="${input}"
	else
		input_file="${input}.sh"
	fi

	cat "$(require_path 'require/support')"
	echo "entrypoint='${input_name}'"
	assemble_dependencies "${input_file}"
	cat "$(require_path 'require/entrypoint')"
}

assemble_dependencies ()
{
	local require_on_include='assemble_on_include'
	local input_file="${1:-}"

	require "${input_file}" > "${assemble_dir}/required_modules"

	if require_is_loaded "require.sh" ""
	then
		echo "require_loaded='${require_loaded}'"
		cat "$(require_path 'require.sh')"
	else
		echo 'require () ( : )'
	fi

	cat "${assemble_dir}/required_modules"
}


assemble_on_include ()
{
	local target="$(basename ${1})"
	if test "${target}" != 'require.sh'
	then
		test "${target%*.sh}.sh" = "${target}" || return 0
		require_on_include "${1}"
		cat "${1}"
	fi
}
