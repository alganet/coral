string_repeat ()
{
	printf "%${2:-10}s" | sed "s/ /${1:-}/g"
}
