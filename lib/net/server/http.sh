##
 # net_server_http.sh - creates http servers
 ##

require 'fs/tempdir.sh'

net_server_http_abort ()
{
	local buffer_dir="${1}"
	for job in $(jobs -p)
	do
		kill "${job}" 2>/dev/null
	done
	rm -rf "${buffer_dir}"
	return 1
}

net_server_http_buffer ()
{
	local buffer_dir="${1}"
	local buffer_name
	local buffer_file

	if test -z "${buffer_name:-}"
	then
		buffer_name="$(
			od -N4 -tu /dev/random | sed -n '1 {s#[^0-9]\|\s#-#;p;q}'
		)"
		buffer_file="${buffer_dir}/${buffer_name}"

		mkfifo "${buffer_file}"
	fi
	echo "${buffer_file}"
}


net_server_http_response ()
{
	local reldir="${REQUEST_URI}"
	local target="${rootdir}${reldir:-/}"
	local type
	local length

	if test -f "${target}"
	then
		case "${target##*.}" in
			"html" )
				type='text/html'
				;;
			"css" )
				type='text/css'
				;;
			"png" )
				type='image/png'
				;;
			"jpg" )
				type='image/jpeg'
				;;
			"gif" )
				type='image/gif'
				;;
			"js" )
				type='text/javascript'
				;;
			* )
				type='text/plain'
				;;
		esac
		length=$(wc -c < "${target}")
		cat <<-MSG
			HTTP/1.1 200 OK
			Connection: keep-alive
			Content-Type: ${type}
			Content-Length: ${length}
			${CR}
			$(cat "${target}")
			${CR}
		MSG
	else
		cat <<-MSG
			HTTP/1.1 404 Not Found
			Connection: keep-alive
			Content-Length: 0
			${CR}
			${CR}
		MSG
	fi


	return
}


net_server_http_parse_request ()
{
	local REQUEST_METHOD
	local REQUEST_URI
	local SERVER_PROTOCOL

	while read -r REQUEST_METHOD REQUEST_URI SERVER_PROTOCOL
	do
		if ( test "${SERVER_PROTOCOL:-}" = "HTTP/1.1${CR}" ||
			test "${SERVER_PROTOCOL:-}" = "HTTP/1.1" ) &&
			test -n "${REQUEST_METHOD:-}"
		then
			"${callback}"
		fi
	done < "${buffer_in}"
}

net_server_http ()
{
	local rootdir="${1:-$PWD}"
	local CR
	local callback="net_server_http_response"
	local connector1="nc -v -p ${2:-9999} -l 127.0.0.1"
	local connector2="nc -v -l 127.0.0.1:${2:-9999}"
	local connector3="nc -v -l 127.0.0.1 ${2:-9999}"
	local buffer_in
	local buffer_out
	local buffer_dir
	trap 'net_server_http_abort "${buffer_dir}"' 2

	CR="$(printf '\r')"
	buffer_dir="$(fs_tempdir 'net_server_http')"

	while true
	do
		buffer_in="$(net_server_http_buffer "${buffer_dir}")"
		buffer_out="$(net_server_http_buffer "${buffer_dir}")"
		(
			${connector1} 2>/dev/null ||
			${connector2} 2>/dev/null ||
			${connector3} 2>/dev/null || net_server_http_abort "${buffer_dir}"
		) < "${buffer_out}" > "${buffer_in}" &

		net_server_http_parse_request > "${buffer_out}" &
		wait
	done

	rm -rf "${buffer_dir}"
	return 0
}
