dnl ###
dnl ### NSC 2.0 -- Zone File Generator
dnl ### (c) 1997 Martin Mares <mj@gts.cz>
dnl ###
dnl ### Usage: m4 nsc.m4 domain-source-files >zone-file
dnl ###    Or: m4 nsc.m4 domain-source-files >rev-zone-file -DREVERSE=net-ip -DREVBASE=net-ip-to-SOA
dnl ###

# Default values of zone parameters:

define(refresh, hours(8))
define(retry, hours(2))
define(expire, days(7))
define(minttl, days(1))
define(nsname, translit(esyscmd(`hostname -f'),`
',`'))
define(maintname, `root'.`corr_dot(nsname)')

# Domain name

define(whole_domain, `ifdef(`REVERSE', `define(esrever,revaddr(REVBASE))esrever.in-addr.arpa', `Xdomain')'))
define(dotdomain, `ifelse(Xdomain,,,.Xdomain)')

# Generate reverse addressing if needed

define(stop_if_rev, `ifdef(`REVERSE', `divert(-1)')')
define(mk_PTR, `divert
revaddr(substr($1,incr(len(REVERSE))))	PTR	$2`'ifelse(index($2,`.'),-1,`dotdomain.',`')')

define(mk_ptr, `ifelse(REVERSE, substr($1, 0, len(REVERSE)),`mk_PTR($1,$2)')')
define(emit_ptr, `ifdef(`REVERSE', `mk_ptr($1,$2)divert(-1)')')

# Version number

define(ver_file, ifdef(`VERS',`VERS',`.nsc_version'))
define(today_code, translit(esyscmd(`date +"%Y%m%d"'),`
',`'))
sinclude(ver_file)
ifelse(today_code, last_today_code, `', `define(`subver_num',1)')
syscmd(echo >ver_file "`define'(`last_today_code',today_code) `define'(`subver_num', incr(subver_num))")
define(Subver_num, format(`%02d', subver_num))
define(version,`today_code`'Subver_num')

# Host / Subdomain name

define(emit_name, `ifdef(`keep_addr', `keep_addr`'undefine(`keep_addr')', `$1')')

# SOA record

define(DO_SOA, `divert; Primary file for the whole_domain domain generated on curdate

corr_dot(whole_domain)	`SOA'	corr_dot(nsname) maintname (
		version refresh retry expire minttl )')
define(SOA, `ifdef(`Xdomain',`define(`Xdomain',$1)',`define(`Xdomain',$1)DO_SOA')')

# NS record

define(exNS, `emit_name	`NS'	corr_dot($1)
')
define(NS, `iterate(`exNS', `$@')dnl')

# MX record

define(exMX, `emit_name	`MX'	corr_dot($1)
')
define(MX, `stop_if_rev`'iterate(`exMX', `$@')dnl')

# HINFO record

define(HI, `	HINFO	"$1" "$2"')

# Host records

define(exH, `emit_ptr($1, cname)	A	$1
')
define(H, `define(`cname', $1)stop_if_rev`'$1`'iterate(`exH', `shift($@)')dnl')

# Reverse-only host records

define(exRH, `emit_ptr($1, cname)')
define(RH, `define(`cname', $1)stop_if_rev`'iterate(`exRH', `shift($@)')dnl')

# Domain records

define(D, `stop_if_rev`'define(`keep_addr', $1)define(`cname', $1)dnl')

# Addressless entry (for example mail alias)

define(HH, `define(`keep_addr', $1)define(`cname', $1)dnl')

# ALIASing records

define(exALIAS, `$1	CNAME cname
')
define(ALIAS, `iterate(`exALIAS', `$@')dnl')

# Cleanup actions

define(cleanup, `
localhost	A	127.0.0.1
divert`'ifdef(`REVERSE',`
')')
m4wrap(`cleanup')
