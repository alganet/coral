##
 # fs_path.sh - solves filesystem paths
 ##

fs_path ()
{
	local IFS
	local solved
	local target_path

	target_path="${2:-${PATH:-}}"
	IFS=':'

	for solved in ${target_path}
	do
		if test -f "${solved}/${1}"
		then
			printf '%s\n' "${solved}/${1}"
			return
		fi
	done

	return 0
}
