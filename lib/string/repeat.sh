##
 # string_repeat.sh - generates random numbers
 ##

string_repeat ()
{
	printf "%${2:-10}s" | sed "s/ /${1:-}/g"
}
