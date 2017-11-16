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
		while read -r line
		do
			printf %s\\n "${line}"
		done < "${1}"
	else
		while read -r line
		do
			printf %s\\n "${line}"
		done
	fi

	IFS="${oldifs}"

	return 0
}
