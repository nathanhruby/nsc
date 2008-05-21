dnl ###
dnl ### NSC -- Library Functions For DNS Processing
dnl ### (c) 1997--2008 Martin Mares <mj@ucw.cz>
dnl ###
divert(-1)

# NSC version

define(`NSCVER', `NSC 3.1')

# Current date and time

define(`CURRENT_DATE', translit(esyscmd(`date'),`
',`'))

# Time conversion

define(MINUTES, `eval($1*60)')
define(HOURS, `eval($1*3600)')
define(DAYS, `eval($1*86400)')

# Since slashes can occur in zone names, we convert them to @'s

define(nsc_file_name, `translit($1,/,@)')

# Reverse an IP address

define(nsc_revIPa, `ifelse($#, 1, `$1', `nsc_revIPa(shift($@)).$1')')
define(nsc_revaddr, `nsc_revIPa(translit($1, `.', `,'))')

# Fix up dots in a name: if the name is not simple (i.e., it contains at least one dot),
# ensure that it ends with a dot.

define(nsc_corr_dot, `ifelse(substr($1,decr(len($1))),.,$1,$1`'ifelse(index($1,.),-1,,.))')

# Normalize IPv6 address

define(nsc_if_v6, `ifelse(index($1,:),-1,`$3',`$2')')

define(nsc_norm_v6, `nsc_norm_v6_z(ifelse(regexp($1,`::.*::'),-1,`ifelse(index($1,::),-1,`nsc_norm_v6_nn($1)',`nsc_norm_v6_cc($1)')',`nsc_bad_v6($1)'))')
# If there is no ::, check the number of :'s
define(nsc_norm_v6_nn, `ifelse(nsc_extract_colons($1),:::::::,$1,`nsc_bad_v6($1)')')
# Replace :: by the right number of :'s to get 8 (possibly empty) components
define(nsc_norm_v6_cc, `regexp($1,`\(.*\)::\(.*\)',`\1'nsc_n_times(eval(9-len(nsc_extract_colons($1))),:)`\2')')
# Delete everything except colons
define(nsc_extract_colons, `ifelse(index($1,:),-1,,`:nsc_extract_colons(regexp($1,`\(.*\):\(.*\)',`\1\2'))')')
# Repeat a given string N times
define(nsc_n_times, `ifelse($1,0,,`$2`'nsc_n_times(eval($1-1),`$2')')')
# Pad each component to 4 hex digits and convert them to lowercase
define(nsc_norm_v6_z, `nsc_norm_v6_digs(translit($1,:,`,'))')
define(nsc_norm_v6_digs, `nsc_norm_v6_dig($1)`'ifelse($#,1,,:`nsc_norm_v6_digs(shift($@))')')
define(nsc_norm_v6_dig, `ifelse(eval(len($1) > 4),1,`nsc_bad_v6($1)',`nsc_n_times(eval(4-len($1)),0)`'translit($1,A-F,a-f)')')
# Report a fatal error in IPv6 address
define(nsc_bad_v6, `nsc_fatal_error(`Invalid IPv6 address: '$1)')

# Reverse an IPv6 address or block

define(nsc_revaddr6, `substr(nsc_do_revaddr6(nsc_norm_v6($1)),1)')
define(nsc_do_revaddr6, `ifelse($1,,,substr($1,0,1),:,`nsc_do_revaddr6(substr($1,1))',`nsc_do_revaddr6(substr($1,2)).substr($1,1,1).substr($1,0,1)')')
define(nsc_revblock6, `nsc_do_revblock6(translit($1,/,`,'))')
define(nsc_do_revblock6, `substr(nsc_revaddr6($1),dnl
ifelse(eval($2%4),0,`eval(64-$2/2)',`nsc_fatal_error(`Prefixes must respect hex digit boundary')'))')

# Iteration

define(nsc_itera, `ifelse($1,,,`nsc_iter($1)')`'ifelse($#,1,,`nsc_itera(shift($@))')')
define(nsc_iterate, `define(`nsc_iter', defn(`$1'))nsc_itera(shift($@))')

# Generate name of reverse domain

define(REV, `nsc_if_v6($1,`nsc_revblock6($1).ip6.arpa',`nsc_revaddr($1).in-addr.arpa')')

# A for loop macro from m4 doc

define(`nsc_forloop',
   `pushdef(`$1', `$2')nsc__forloop(`$1', `$2', `$3', `$4')popdef(`$1')')
define(`nsc__forloop',
   `$4`'ifelse($1, `$3', ,
   `define(`$1', incr($1))nsc__forloop(`$1', `$2', `$3', `$4')')')

# Reporting errors

define(`nsc_fatal_error', `errprint(`NSC error: $1
')m4exit(1)')

# Default values of parameters

define(`NAMED_RESTART_CMD', `ndc reload')

define(`BIND_OPTIONS', `	# Other options can be added here via macro `BIND_OPTIONS'')

define(`ROOT', `/etc/named')
define(`CFDIR', `cf')
define(`ZONEDIR', `zone')
define(`BAKDIR', `bak')
define(`VERSDIR', `ver')
define(`ROOTCACHE', `root.cache')

define(`REFRESH', HOURS(8))
define(`RETRY', HOURS(2))
define(`EXPIRE', DAYS(14))
define(`MINTTL', DAYS(1))
define(`NSNAME', translit(esyscmd(`hostname -f'),`
',`'))
define(`MAINTNAME', `root'.`nsc_corr_dot(NSNAME)')

# And finally we change comments to semicolons to be compatible with the zone files

changecom(;)

; User-defined parts of configuration

include(CFDIR/config)
