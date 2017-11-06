# https://unix.stackexchange.com/questions/76162/how-do-i-capture-the-return-status-and-use-tee-at-the-same-time-in-korn-shell

shell_pipe ()
{
	local argument
	local cursor=1
	local position=1
	local shell_pipe_status=0
	local callback=
	local current_chunk=

	# Creates the code to nest redirects between the commands
	for argument in "${@:-}"
	do
		case ${argument} in
			( '--' )
				callback="
					${callback} {
						${current_chunk} 3>&-
						echo shell_pipe_status_${cursor}=\$? >&3
					} 4>&- |
				"
				cursor=$((${cursor}+1))
				current_chunk=
				;;
			( * )
				current_chunk="${current_chunk} \"\${${position}}\""
				;;
		esac

		position=$((${position}+1))
	done

	# Runs the pipes
	{ eval "$(
			exec 3>&1
			eval "
				${callback} ${current_chunk} 3>&- >&4 4>&-
				echo shell_pipe_status=\$?
			"
		)"
	} 4>&1

	return "${shell_pipe_status}"
}
