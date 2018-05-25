##
 # fs_lines.sh - writes contents of files to stdout
 ##

fs_lines ()
{
	local line
	local IFS

	if test -e "${1:-}"
	then
		# Reading from file descriptor
		exec < "${1}"
	fi

	IFS=
	while read -r line
	do
		printf '%s\n' "${line}"
	done

	return 0
}
