##
 # coral.sh
 ##

require 'require.sh'
require 'spec.sh'
require 'assemble.sh'
require 'shell/route.sh'

coral ()
{
	if test -z "${1:-}"
	then
		echo "No arguments. Try ${0} --help" 1>&2
		return 1
	fi

	shell_route_options_only=true \
		shell_route 'coral' "${@:-}" ||
			coral_run "${@:-}"
}

coral_run ()
{
	local require_path="${require_path:-}${require_path:+:.}"
	local target="${1:-}"
	local target_file="$(echo "${target}" | tr '_' '/').sh"
	shift

	require "${target_file}"
	"${target}" "${@:-}"
}

coral_option_help ()
{
	cat <<-HELPTEXT
		Usage: coral [ARGUMENTS] COMMAND
		       coral [ARGUMENTS] MODULE

		Commands:
		  status      Displays coral context status
		  spec        Runs tests from specifications
		  assemble    Builds shell script executable bundles

		Options:
		  --help      Displays this help
		  --version   Displays version information

		MODULE can be any require.sh compatible module in the current
		require_path.

	HELPTEXT
}
