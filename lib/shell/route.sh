##
 # shell_route.sh - dispatches commands and options to shell functions
 ##

shell_route ()
{
	local namespace="${1}"
	local argument="${2:-}"
	local short
	local long
	local long_name
	local long_value
	local target

	if test "" = "${argument}"
	then
		"${namespace}_${shell_route_default:-empty_command}"
		return $?
	fi

	short="${argument#*-}"
	long="${short#*-}"

	shift 2

	if test "${argument}" = "--${long}"
	then
		long_name="${long%%=*}"

		if test "${long}" != "${long_name}"
		then
			long_value="${long#*=}"
			long="${long_name}"
			set -- "${long_value}" "${@:-}"
		fi

		target="${namespace}_${shell_route_option:-option_}${long}"
	elif test "${argument}" = "-${short}"
	then
		target="${namespace}_${shell_route_option:-option}_${short}"
	elif test -z "${shell_route_options_only:-}"
	then
		target="${namespace}_${shell_route_command:-command}_${long}"
	else
		return 1
	fi

	set -- "${target:-:}" "${@:-}"

	if test -n "${shell_route_name:-}"
	then
		echo "${@:-}"
		return
	fi

	"${@:-}"
}
