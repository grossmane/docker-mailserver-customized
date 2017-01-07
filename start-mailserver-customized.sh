#!/bin/bash

##########################################################################
# >> DEFAULT VARS
#
# add them here. 
# Example: DEFAULT_VARS["KEY"]="VALUE"
##########################################################################
declare -A DEFAULT_VARS
DEFAULT_VARS["MYSQL_HOST"]="${MYSQL_HOST:="mysql"}"
DEFAULT_VARS["MYSQL_DBNAME"]="${MYSQL_DBNAME:="postfix"}"
DEFAULT_VARS["MYSQL_USERNAME"]="${MYSQL_USERNAME:="postfix"}"
DEFAULT_VARS["MYSQL_PASSWORD"]="${MYSQL_PASSWORD:="postfix"}"
DEFAULT_VARS["MYSQL_DEFAULT_PASS_SCHEME"]="${MYSQL_DEFAULT_PASS_SCHEME:="PLAIN-MD5"}"
##########################################################################
# << DEFAULT VARS
##########################################################################


##########################################################################
# >> REGISTER FUNCTIONS
#
# add your new functions/methods here. 
#
# NOTE: position matters when registering a function in stacks. First in First out
# 		Execution Logic: 
# 			> check functions
# 			> setup functions
# 			> fix functions
# 			> misc functions
# 			> start-daemons
#
# Example: 
# if [ CONDITION IS MET ]; then
#   _register_{setup,fix,check,start}_{functions,daemons} "$FUNCNAME"
# fi
#
# Implement them in the section-group: {check,setup,fix,start}
##########################################################################
function register_functions() {
	notify 'taskgrp' 'Initializing setup'
	notify 'task' 'Registering check,setup,fix,misc and start-daemons functions'

	################### >> setup funcs

    _register_setup_function "_setup_mysql_connection"

	################### << setup funcs

}
##########################################################################
# << REGISTER FUNCTIONS
##########################################################################


##########################################################################
# >> protected register_functions
##########################################################################
function _register_setup_function() {
    FUNCS_SETUP+=($1)
    notify 'inf' "$1() registered"
}

##########################################################################
# << protected register_functions
##########################################################################


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !  CARE --> DON'T CHANGE, unless you exactly know what you are doing
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# >>


##########################################################################
# >> CONSTANTS
##########################################################################
declare -a FUNCS_SETUP
declare -a FUNCS_FIX
declare -a FUNCS_CHECK
declare -a FUNCS_MISC
declare -a DAEMONS_START
declare -A HELPERS_EXEC_STATE
##########################################################################
# << CONSTANTS
##########################################################################

function notify () {
	c_red="\e[0;31m"
	c_green="\e[0;32m"
	c_brown="\e[0;33m"
	c_blue="\e[0;34m"
	c_bold="\033[1m"
	c_reset="\e[0m"

	notification_type=$1
	notification_msg=$2
	notification_format=$3
	msg=""

	case "${notification_type}" in
		'taskgrp')
			msg="${c_bold}${notification_msg}${c_reset}"
			;;
		'task')
			if [[ ${DEFAULT_VARS["DMS_DEBUG"]} == 1 ]]; then
				msg="  ${notification_msg}${c_reset}"
			fi
			;;
		'inf')
			if [[ ${DEFAULT_VARS["DMS_DEBUG"]} == 1 ]]; then
				msg="${c_green}  * ${notification_msg}${c_reset}"
			fi
			;;
		'started')
			msg="${c_green} ${notification_msg}${c_reset}"
			;;
		'warn')
			msg="${c_brown}  * ${notification_msg}${c_reset}"
			;;
		'err')
			msg="${c_red}  * ${notification_msg}${c_reset}"
			;;
		'fatal')
			msg="${c_red}Error: ${notification_msg}${c_reset}"
			;;
		*)
			msg=""
			;;
	esac

	case "${notification_format}" in
		'n')
			options="-ne"
	  	;;
		*)
  		options="-e"
			;;
	esac

	[[ ! -z "${msg}" ]] && echo $options "${msg}"
}

function defunc() {
	notify 'fatal' "Please fix your configuration. Exiting..." 
	exit 1
}


function setup() {
    notify 'taskgrp' 'Configuring mail server'
    for _func in "${FUNCS_SETUP[@]}";do
        $_func
    done
}

function _setup_mysql_connection() {
	notify 'task' 'Setting up MySQL Connection'

    sed -i -r 's~%%MYSQL_HOST%%~'${MYSQL_HOST}'~g' /etc/dovecot/dovecot-sql.conf.ext /etc/postfix/mysql-email2email.cf /etc/postfix/mysql-protected_users.cf /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-lists-alias-maps.cf /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-system-alias-maps.cf /etc/postfix/mysql-virtual-verteiler-alias-maps.cf
    sed -i -r 's~%%MYSQL_DBNAME%%~'${MYSQL_DBNAME}'~g' /etc/dovecot/dovecot-sql.conf.ext /etc/postfix/mysql-email2email.cf /etc/postfix/mysql-protected_users.cf /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-lists-alias-maps.cf /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-system-alias-maps.cf /etc/postfix/mysql-virtual-verteiler-alias-maps.cf
    sed -i -r 's~%%MYSQL_USERNAME%%~'${MYSQL_USERNAME}'~g' /etc/dovecot/dovecot-sql.conf.ext /etc/postfix/mysql-email2email.cf /etc/postfix/mysql-protected_users.cf /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-lists-alias-maps.cf /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-system-alias-maps.cf /etc/postfix/mysql-virtual-verteiler-alias-maps.cf
    sed -i -r 's~%%MYSQL_PASSWORD%%~'${MYSQL_PASSWORD}'~g' /etc/dovecot/dovecot-sql.conf.ext /etc/postfix/mysql-email2email.cf /etc/postfix/mysql-protected_users.cf /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-lists-alias-maps.cf /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-system-alias-maps.cf /etc/postfix/mysql-virtual-verteiler-alias-maps.cf
	sed -i -r 's~%%MYSQL_DEFAULT_PASS_SCHEME%%~'${MYSQL_DEFAULT_PASS_SCHEME}'~g' /etc/dovecot/dovecot-sql.conf.ext

	notify 'inf' "MySQL Connection configured"
}

##########################################################################
# << Setup Stack
##########################################################################


register_functions

setup

/usr/local/bin/start-mailserver.sh
exit 0
