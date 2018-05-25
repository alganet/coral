##
 # fs_lines.sh - writes contents of files to stdout
 ##

fs_lines ()
{
	local line
	local fs_lines_ifs

	if test -e "${1:-}"
	then
		# Reading from file descriptor
		exec < "${1}"
	fi

	# Removes the internal field separator
	fs_lines_ifs="${IFS}"
	IFS=

	while read -r line
	do
		printf '%s\n' "${line}"
	done

	# Restores the internal field separator
	IFS="${fs_lines_ifs}"

	return 0
}
