dnl ###
dnl ### NSC 2.0 -- Library Functions For DNS Processing
dnl ### (c) 1997 Martin Mares <mj@gts.cz>
dnl ###
divert(-1)

# Current date and time

define(`curdate', translit(esyscmd(`date'),`
',`'))

# Time conversion

define(minutes, `eval($1*60)')
define(hours, `eval($1*3600)')
define(days, `eval($1*86400)')

# Reversal of IP address

define(revIPa, `ifelse($#, 1, `$1', `revIPa(shift($@)).$1')')
define(revaddr, `revIPa(translit($1, `.', `,'))')

# Add explicit dot at the end if the name contains domain part

define(corr_dot, `$1`'ifelse(index($1,`.'),-1,,`.')')

# Iteration

define(itera, `ifelse($#, 1, `iter($1)', `iter($1)`'itera(shift($@))')')
define(iterate, `define(`iter', defn(`$1'))itera($2)')
