##
 # fs_lines.sh - writes contents of files to stdout
 ##

fs_lines ()
{
	IFS=

	if test -e "${1:-}"
	then
		# Reading from file descriptor
		fs_lines_loop < "${1}"
	else
		# Reading from stdin
		fs_lines_loop
	fi

	return 0
}

fs_lines_loop ()
{
	local line

	while read -r line
	do
		printf '%s\n' "${line}"
	done
}
