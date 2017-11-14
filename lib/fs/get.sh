##
 # fs_get.sh - writes contents of files to stdout
 ##

fs_get ()
{
	local line

	local oldifs="${IFS}"
	local IFS=

	if test -e "${1:-}"
	then
		exec < "${1}"
	fi

	while read -r line
	do
		printf %s\\n "${line}"
	done

	IFS="${oldifs}"
	return 0
}
