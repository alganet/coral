##
 # fs_basename.sh - gets the name part of a path
 ##

fs_basename ()
{
	echo "${1##*/}"
}
