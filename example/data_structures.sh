# This example is subject to change

data_structures () {
	local breakfast= fruit_list= fruits_iterator= fruit_reference= fruit=

	# Declaring and working with pseudotypes
	val fruit_list = [ Lst ="banana" ="apple" ="orange" ="grape" ]
	val breakfast = [ Map :beverage ="coffee" :fruit $fruit_list ]

	# Prints the internal data structure
	toenv $breakfast
	_print "## Internals\n$REPLY"

	# Dumps it in a human readable way
	dump $breakfast
	_print "## Dumped\n$REPLY\n\n"

	# How to iterate over a traversable type
	val fruits_iterator =@ $fruit_list
	for fruit_reference in $fruits_iterator
	do
		val fruit =@ $fruit_reference
		_print "Fruit was served: $fruit\n"
	done
}
