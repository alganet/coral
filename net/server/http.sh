##
 # net_server_http.sh - creates http servers
 ##

require 'fs/tempdir.sh'

net_server_http_abort ()
{
	local buffer_dir="${1}"
	kill $(jobs -p) 2>/dev/null
	rm -rf "${buffer_dir}"
	return 1
}

net_server_http_buffer ()
{
	local buffer_dir="${1}"
	if test -z "${buffer_name:-}"
	then
		local buffer_name="$(
			od -N4 -tu /dev/random | tr " " "-" | tr -d '\n'
		)"
		local buffer_file="${buffer_dir}/${buffer_name}"

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

	while test -e "${buffer_in}" &&
		 read -r REQUEST_METHOD REQUEST_URI SERVER_PROTOCOL
	do
		if test "${SERVER_PROTOCOL:-}" = "HTTP/1.1${CR}" ||
			test "${SERVER_PROTOCOL:-}" = "HTTP/1.1"
		then
			"${callback}"
		fi
	done < "${buffer_in}"
}

net_server_http ()
{
	local rootdir="${1:-$PWD}"
	local CR="$(printf '\r')"
	local callback="net_server_http_response"
	local buffer_dir="$(fs_tempdir 'net_server_http')"
	local connector1="nc -v -p ${2:-9999} -l 127.0.0.1"
	local connector2="nc -v -l 127.0.0.1:${2:-9999}"
	local connector3="nc -v -l 127.0.0.1 ${2:-9999}"
	trap 'net_server_http_abort "${buffer_dir}"' 2

	while true
	do
		local buffer_in="$(net_server_http_buffer "${buffer_dir}")"
		local buffer_out="$(net_server_http_buffer "${buffer_dir}")"
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
