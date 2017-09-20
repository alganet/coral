
tempdir ()
{
	local prefix="${1:-tempdir.sh}"
    local tempdir="$(
    	mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX" 2>/dev/null || :
	)"

    if test -z "${tempdir:-}"
	then
		tempdir="${TMPDIR:-/tmp}/${prefix}."$(
			od -An -N2 -i /dev/random | sed 's/[ 	]*//m'
		)
	    mkdir -m 'u+rwx' "${tempdir}"
	fi

	printf %s "${tempdir}"
}
