##
 # coral.sh — a portable shell script ecosystem
 ##

coral ()
{
	require "${1}.sh"

	"${@:-}"
}
