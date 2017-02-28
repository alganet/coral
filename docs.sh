require 'tempdir.sh'
require 'task.sh'

docs ()
{
	local document_dir="$(cd "$(tempdir doc)"; pwd)"
	local docs_prefix="Docs_"

	Docs_Main ()
	{
		:
	}

	eval "$(docs_transpile "${@:-}")"
}

docs_transpile ()
{
	test ! -z "${1:-}" || return 1

	local document_path="${1}"
	local reference_opened='no'
	local block_opened='no'
	local fence_opened='no'
	local previous_reference=
	local is_previous_reference=

	while IFS= read -r document_line
	do
		if test "${reference_opened}" = 'yes'
		then
			docs_body_line || continue
		fi

		local is_reference="${document_line#\[-\]:}"

		if test "[-]:${is_reference}" = "${document_line}"
		then
			docs_close

			local is_file="${is_reference#*:./}"
			local is_task="${is_reference%%:./*}"

			if test "${is_task}:./${is_file}" = "${is_reference}"
			then
				docs_reference_line ${is_task}
			else
				docs_reference_line ${is_reference}
			fi

			printf '\n'
			reference_opened='yes'
		fi

	done < "${document_path}"

	docs_close

	echo "task_run '${docs_prefix}' Main"
}

docs_body_line ()
{
	if test "${block_opened}" = 'no' &&
	   test -z "${document_line}"
	then
		printf '\t_blank\n'
		return 1
	fi

	if test "\`\`\`" = "${document_line}"
	then
		fence_opened='no'
		return 1
	fi

	local is_fenced_block="${document_line#\`\`\`}"

	if test "\`\`\`${is_fenced_block}" = "${document_line}"
	then
		fence_opened='yes'
		return 1
	fi

	local is_spaced_block="${document_line#    }"

	if test "    ${is_spaced_block}" = "${document_line}"
	then
		block_opened='yes'
		docs_code_line "${is_spaced_block}"
		return 1
	elif test "${fence_opened}" = 'no'
	then
		local is_reference="${document_line#\[-\]:}"
		local is_checklist_open="${document_line# - \`}"
		local is_checklist="${is_checklist_open%%\`*}"
		local checklist_comment="${is_checklist_open##*\`}"

		if test " - \`${is_checklist_open}" = "${document_line}"
		then
			docs_check_line
		elif test "[-]:${is_reference}" != "${document_line}" &&
		     test ! -z "${document_line}"
		then
			docs_text_line
		fi
	fi


	if test "${fence_opened}" = 'yes'
	then
		docs_code_line "${document_line}"
	fi

	if test "${block_opened}" = 'yes'
	then
		block_opened='no'
	fi

}

docs_code_line ()
{
	local is_command_line="${1#\$ }"

	if test "\$ ${is_command_line}" = "${1}"
	then
		printf '\t_call	%s\n' "'${is_command_line}'"
	else
		printf '\t_expect	%s\n' "'${1}'"
	fi
}

docs_check_line ()
{
	if test "returns ${is_checklist#returns }" = "${is_checklist}"
	then
		printf '\t_return	%s\n' \
			"'${is_checklist#returns }' '${checklist_comment}'"
	else
		printf '\t_check	%s\n' \
			"'${is_checklist}' '${checklist_comment}'"
	fi


}
docs_text_line ()
{
	while true
	do
		local pre_link="${document_line%%\[*}"
		local has_link_open="${document_line#*\[}"
		local link_name="${has_link_open%%\]\(*}"
		local has_title_open="${has_link_open#*\]\(}"
		local link_href="${has_title_open%%)*}"
		local pos_link="${has_title_open#*\)}"
		local full_link="[${link_name}]($link_href)"
		local parse_check="${pre_link}${full_link}${pos_link}"

		if test "${parse_check}" = "${document_line}"
		then
			printf '\t_text	%s\n' "'${pre_link}'"
			printf '\t_link	%s %s\n' "'${link_href}'" "'${link_name}'"
			document_line="${pos_link}"
		else
			printf '\t_text	%s\n' "'${pos_link}'"
			break
		fi
	done
}

docs_reference_line ()
{
	local reference_name="${1}"

	printf '%s%s ()\n{' "${docs_prefix}" "${reference_name}"

	if test "${2:-}" != "(" || test "${#}" -lt 2
	then
		return
	fi

	shift 2

	while test "${#}" -gt 1
	do
		if test "${1}" = "or"
		then
			printf ' ||'
			shift
			continue
		fi

		if test "${1}" = "and"
		then
			printf ' &&'
			shift
			continue
		fi

		if test ":${1#:}" = "${1}"
		then
			printf '\n\t_nest	%s ' "${1#:}"
		fi

		shift
	done
}

docs_close ()
{

	if test "${reference_opened}" = 'yes'
	then
		if test "${is_task:-}" != "${is_file:-}" &&
		   test ! -z "${is_task:-}"
		then
			printf '\t_file	%s\n}\n' "'${is_file}'"
		else
			printf '\t_done\n}\n'
		fi
	fi
}
