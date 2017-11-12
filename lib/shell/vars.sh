##
 # shell_vars.sh - normalizes shell variables
 ##

shell_vars ()
{
	shell_vars_fill | sort -n
}

shell_vars_fill ()
{
	shell_var_line=''
	shell_var_value=''

	if test -n "${POSH_VERSION-}"
	then
		while read -r shell_var_line
		do
			shell_var_value="$(eval printf %s "\${${shell_var_line}}")"
			printf %s\\n "${shell_var_line}='${shell_var_value}'"
		done
		return
	fi

	while read -r shell_var_line
	do
		if test "${shell_var_line#*=}" != "${shell_var_line}" &&
		   test "${shell_var_line#BASHOPTS=*}" = "${shell_var_line}" &&
		   test "${shell_var_line#PATH=*}" = "${shell_var_line}" &&
		   test "${shell_var_line#LINEO=*}" = "${shell_var_line}" &&
		   test "${shell_var_line#IFS=*}" = "${shell_var_line}"
		then
			printf %s\\n "${shell_var_line}"
		elif test "${shell_var_line%% ()} ()" = "${shell_var_line}"
		then
			return
		fi
	done
}
