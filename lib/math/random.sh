
math_random ()
{
	echo ${RANDOM:-$(od -An -N3 -i /dev/random)}
}
