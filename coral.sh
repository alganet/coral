# coral.sh - A library to load and launch other libraries
#
coral ()
{
	require "${1}.sh"

	"${@:-}"
}
