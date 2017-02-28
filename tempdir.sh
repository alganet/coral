
tempdir ()
{
    local tempdir="$(
    	mktemp -d \
    	"${TMPDIR:-/tmp}/${1:-tempdir}.XXXXXX" 2>/dev/null || :
	)"
    if test -z "${tempdir:-}"
	then
		tempdir="${TMPDIR:-/tmp}/${1:-tempdir}."$(
			od -An -N2 -i /dev/random | sed 's/[ 	]*//m'
		)
	    mkdir -m 'u+rwx' "${tempdir}"
	fi

	printf %s "${tempdir}"
}
