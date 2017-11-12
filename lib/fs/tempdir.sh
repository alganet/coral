##
 # fs_tempdir.sh - creates temporary directories
 ##

require 'math/random.sh'

fs_tempdir ()
{
	local prefix="${1:-tempdir.sh}"
	local systmp="${TMPDIR:-/tmp}"
    local tempdir

    tempdir="$(mktemp -d "${systmp}/${prefix}.XXXXXX" 2>/dev/null || :)"

    if test -z "${tempdir:-}"
	then
		tempdir="${systmp}/${prefix}.$(math_random)"
	    mkdir -m 'u+rwx' "${tempdir}"
	fi

	echo "${tempdir}"
}
