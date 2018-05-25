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
	od -A n -t u1 -N100 '/dev/random' | {
		local random_integers
		read -r random_integers
		printf %s "${random_integers}" |
			sed "
				s/[^0-9]//g
				s/^0*//
				s/^\($(string_repeat '.' 20)\).*$/\1/
			"
		return 0
	}
}
