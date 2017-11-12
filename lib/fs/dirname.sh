##
 # fs_dirname.sh - gets the directory part of a path
 ##

fs_dirname ()
{
	echo "${1%/*}"
}
