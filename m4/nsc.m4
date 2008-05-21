dnl ###
dnl ### NSC -- Zone File Generator
dnl ### (c) 1997--2008 Martin Mares <mj@ucw.cz>
dnl ###
dnl ### Usage: m4 -DVERS=path-to-version-file nsc.m4 domain-source-files >zone-file
dnl ###
include(m4/dnslib.m4)

# Version number

ifdef(`VERS',`',`nsc_fatal_error(`VERS macro not defined')')

define(TODAY_CODE, translit(esyscmd(`date +"%Y%m%d"'),`
',`'))
sinclude(VERS)
# Backward compatibility with NSC 2.x version files
ifdef(`last_today_code', `define(`LAST_TODAY_CODE',last_today_code)undefine(`last_today_code')')
ifdef(`subver_num', `define(`SUBVER_NUM',subver_num)undefine(`subver_num')')
ifelse(TODAY_CODE, LAST_TODAY_CODE, `', `define(`SUBVER_NUM',1)')
syscmd(echo >VERS "`define'(`LAST_TODAY_CODE',TODAY_CODE) `define'(`SUBVER_NUM',incr(SUBVER_NUM))")
ifelse(eval(SUBVER_NUM > 99),1,`nsc_fatal_error(`Too many zone changes in a single day, you must tweak 'VERS` manually')')
define(`VERSION',TODAY_CODE`'format(`%02d', SUBVER_NUM))

# Record names

define(nsc_set_name, `define(`CURRENT_NAME', nsc_corr_dot($1))define(`PRINT_NAME', CURRENT_NAME)')
define(nsc_emit_name, `ifdef(`PRINT_NAME', `PRINT_NAME`'undefine(`PRINT_NAME')', `')')
define(nsc_abs_name, `ifelse(CURRENT_NAME, translit(CURRENT_NAME,.,:), CURRENT_NAME.CURRENT_DOMAIN, CURRENT_NAME)')

# SOA record

define(nsc_SOA, `
$ORIGIN CURRENT_DOMAIN
$TTL	MINTTL
nsc_emit_name	`SOA'	nsc_corr_dot(NSNAME) MAINTNAME (
		VERSION REFRESH RETRY EXPIRE MINTTL )')
define(SOA, `ifdef(`CURRENT_DOMAIN',`ifdef(`REVERSE_MODE',,`nsc_fatal_error(`SOA record defined twice')')')dnl
define(`CURRENT_DOMAIN',$1.)dnl
nsc_set_name(CURRENT_DOMAIN)dnl
ifdef(`REVERSE_MODE',,`nsc_SOA')')

# Reverse zones

define(REVERSE, `divert(-1)
	define(`REVERSE_MODE', `')
	nsc_if_v6($1,`
		define(`REVNET6', nsc_revblock6($1))
	',`
		define(`REVNET', `$1.')
		define(`REVLOW', `$2')
		define(`REVHIGH', `$3')
	')
')

define(nsc_mk_PTR, `
	divert`'$1	`PTR'	$2
divert(-1)
')

define(nsc_auto_PTR4, `dnl
ifdef(`REVNET', `
	ifelse(REVNET, substr($1, 0, len(REVNET)), `
		define(`REVX', substr($1, len(REVNET)))
		ifelse(REVLOW, `',
			`nsc_mk_PTR(nsc_revaddr(REVX), $2)',
			`
				ifelse(eval((REVX >= REVLOW) && (REVX <= REVHIGH)), 1, `nsc_mk_PTR(REVX, $2)')
			')
		')
	')dnl
')

define(nsc_auto_PTR6, `dnl
ifdef(`REVNET6', `
	define(`REVA', nsc_revaddr6($1))
	ifelse(REVNET6, substr(REVA, eval(63-len(REVNET6))), `
		nsc_mk_PTR(substr(REVA, 0, eval(62-len(REVNET6))), $2)
		')
	')dnl
')

# A records

define(nsc_AONLY, `nsc_emit_name	nsc_if_v6($1,`AAAA	nsc_norm_v6($1)',``A'	$1')
')
define(nsc_A, `nsc_if_v6($1,`nsc_auto_PTR6',`nsc_auto_PTR4')($1,nsc_abs_name)nsc_AONLY($1)')
define(ADDR, `nsc_iterate(`nsc_A', $@)dnl')
define(DADDR, `nsc_iterate(`nsc_AONLY', $@)dnl')

# Host specification

define(H, `nsc_set_name($1)nsc_iterate(`nsc_A', shift($@))dnl')
define(DH, `nsc_set_name($1)nsc_iterate(`nsc_AONLY', shift($@))dnl')

# Subdomain specification and glue records

define(D, `nsc_set_name($1)dnl')
define(GLUE, `DH($@)')

# NS record

define(nsc_NS, `nsc_emit_name	`NS'	nsc_corr_dot($1)
')
define(NS, `nsc_iterate(`nsc_NS', $@)dnl')

# MX record

define(nsc_MX, `nsc_emit_name	`MX'	nsc_corr_dot($1)
')
define(MX, `nsc_iterate(`nsc_MX', $@)dnl')

# HINFO record

define(HI, `nsc_emit_name	HINFO	"$1" "$2"')

# ALIASing records

define(nsc_ALIAS, `$1	`CNAME' CURRENT_NAME
')
define(ALIAS, `nsc_iterate(`nsc_ALIAS', $@)nsc_set_name(CURRENT_NAME)dnl')

# TXT records

define(TXT, `nsc_emit_name	`TXT'	"$1"')

# RP (responsible person) records

define(RP, `nsc_emit_name	`RP'	nsc_corr_dot($1) nsc_corr_dot($2)')

# CNAME records

define(CNAME, `$1	`CNAME'	nsc_corr_dot($2)')

# Explicit PTR records

define(PTR, `$1	`PTR'	nsc_corr_dot($2)')

# Shortcut for classless reverse delegation of a block

define(REVBLOCK, `nsc_forloop(`i', $2, $3, `i'	`CNAME'	`i'.$1
)D($1)
')

# Cleanup actions

define(nsc_cleanup, `ifdef(`DISABLE_LOCALHOST',,`
; Added automatically (required by RFC 1912)
localhost	A	127.0.0.1
')')
m4wrap(`nsc_cleanup')

divert(0)dnl
`;;;' Primary zone file
`;;;' Generated by NSCVER (nsc.m4) on CURRENT_DATE
`;;;' Please do not edit manually
`'
