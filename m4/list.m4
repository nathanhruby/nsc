dnl ###
dnl ### NSC -- List all defined domains
dnl ### (c) 2003 Martin Mares <mj@ucw.cz>
dnl ###
include(m4/dnslib.m4)

define(`print', `divert(0)$1
divert(-1)')
define(`PRIMARY', `print($1)')
define(`SECONDARY', `print($1)')
