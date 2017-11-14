##
 # fs_dirname.sh - gets the directory part of a path
 ##

require 'string/rtrim.sh'

fs_dirname ()
{
	local name="${1}"

	string_rtrim "/" "${name%/*}"
}
