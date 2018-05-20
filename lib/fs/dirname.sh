##
 # fs_dirname.sh - gets the directory part of a path
 ##

require 'string/rtrim.sh'

fs_dirname ()
{
	local name

	name="${1}"

	# Prints out the first argument up until the first slash, trimming
	# out any slashes on the right side right after
	string_rtrim "/" "${name%/*}"
}
