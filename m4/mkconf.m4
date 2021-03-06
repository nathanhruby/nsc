dnl ###
dnl ### NSC -- BIND Config File Builder
dnl ### (c) 1997--2011 Martin Mares <mj@ucw.cz>
dnl ###
include(m4/dnslib.m4)

# Definition of primary domains

define(`DO_PRIMARY', `divert(0)zone "$1" in {
	type master;
	file "ZONEDIR/nsc_file_name($2)";
ZZ_OPTIONS()dnl
};

divert(-1)')

define(`PRIMARY', `DO_PRIMARY($1,$1)')
define(`REVERSE', `DO_PRIMARY(REV($1),nsc_if_v6($1,`nsc_revblock6($1)',`nsc_revaddr($1)'))')

# Definition of secondary domain

define(`SECONDARY', `divert(0)zone "$1" in {
	type slave;
	file "BAKDIR/nsc_file_name($1)";
	masters { $2; };
ZZ_OPTIONS()dnl
};

divert(-1)')

# Definition of a forwarding zone

define(`FORWARDING', `divert(0)zone "$1" in {
	type forward;
	forward only;
	forwarders { FORWard(shift($@),)};
ZZ_OPTIONS()dnl
};

divert(-1)')

# Blackhole zones

define(`BLACKHOLE', `divert(0)zone "$1" in {
	type master;
	file "zone/blackhole";
};

divert(-1)')

# Root hint zone

define(`ROOTHINT', `divert(0)zone "." in {
	type hint;
	file "ROOTCACHE";
};

divert(-1)')

# Manual insertion of config file material

define(`CONFIG', `divert(0)$1
divert(-1)')

# Setting domain options

define(`ZZ_OPTIONS', `')

define(`ZONE_OPTIONS', `define(`ZZ_OPTIONS', ifelse(`$1',`',`',``	$1''))')

# The preamble

divert(0)dnl
`#'
`#'	BIND configuration file
`#'	Generated by NSCVER (mkconf.m4) on CURRENT_DATE
`#'	Please don't edit manually
`#'

divert(-1)
