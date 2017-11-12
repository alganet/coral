##
 # fs_get.sh - writes contents of files to stdout
 ##

fs_get ()
{
	local line

	local oldifs="${IFS}"
	local IFS=

	while read -r line
	do
		printf %s\\n "${line}"
	done < "${1:-/dev/stdin}"

	IFS="${oldifs}"
	return 0
}
