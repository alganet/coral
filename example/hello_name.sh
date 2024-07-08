# When loading scripts, the main function is the same
# as the script file name.

hello_name () {
	# You must declare all variables as local
	local name=$1

	_print "Hello, $name!\n"
}
