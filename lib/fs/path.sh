##
 # fs_path.sh - solves filesystem paths
 ##

fs_path ()
{
	local solved
	local target_path="${2:-.:${PATH:-}}"
	local IFS=':'

	for solved in ${target_path}
	do
		if test -f "${solved}/${1}"
		then
			printf %s "${solved}/${1}"
			return
		fi
	done
}
