require 'string/ltrim.sh'
require 'string/rtrim.sh'

string_trim ()
{
	string_rtrim "${1}" "$(string_ltrim "${1}" "${2}")"
}
