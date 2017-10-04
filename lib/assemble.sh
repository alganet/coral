##
 # assemble.sh
 ##

require 'require.sh'
require 'tempdir.sh'

assemble ()
{
	local input="${1:-}"
	local output="${2:--}"
	local assemble_dir="$(tempdir 'assemble')"

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
	local input_name="${input%*.sh}"
	local input_file=''
	local input_contents=''
	local require_loaded=''

	if test -f "${input}" &&
	   test "${input_name}.sh" = "${input}"
	then
		input_file="${input}"
	else
		input_file="${input}.sh"
	fi

	cat "$(require_path support)"
	echo "entrypoint='${input}'"
	assemble_dependencies "${input_file}"
	cat "$(require_path entrypoint)"
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
	if test "$(basename ${1})" != 'require.sh'
	then
		cat "${1}"
		require_on_include "${1}"
	fi
}
