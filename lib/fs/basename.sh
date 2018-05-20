##
 # fs_basename.sh - gets the name part of a path
 ##

fs_basename ()
{
	# Prints out the first argument ignoring everything until the first
	# slash '/'
	echo "${1##*/}"
}
