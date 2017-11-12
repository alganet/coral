##
 # math_random.sh - generates random numbers
 ##

require 'string/repeat.sh'

math_random ()
{
	# We are checking if random is empty here, so it is OK to use it.
	#shellcheck disable=SC2039
	(
		echo ${RANDOM:-$(math_random_device)}
	)
}

math_random_device ()
{
	local random_integers
	local num_bytes
	num_bytes="$(string_repeat '.' 20)"

	od '/dev/random' | while read -r random_integers
	do
		printf %s "${random_integers}" |
			sed "s/\s//g;s/^0*//;s/^\(${num_bytes}\).*$/\1/"
		return 0
	done
}
