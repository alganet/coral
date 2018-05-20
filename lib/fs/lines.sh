##
 # fs_lines.sh - writes contents of files to stdout
 ##

fs_lines ()
{
	local line
	local oldifs

	# Removes the internal field separator
	oldifs="${IFS}"
	IFS=

	if test -e "${1:-}"
	then
		# Reading from file descriptor
		while read -r line
		do
			printf %s\\n "${line}"
		done < "${1}"
	else
		# Reading from stdin
		while read -r line
		do
			printf %s\\n "${line}"
		done
	fi

	# Restores the internal field separator
	IFS="${oldifs}"

	return 0
}
