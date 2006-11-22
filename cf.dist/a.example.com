; Domain configuration file for a.example.com

; Records in this network are expected to change often, so we
; decrease the minimum TTL:

define(`MINTTL', 300)

; Also, we'll be referring to a single IP address many times,
; so let's create a macro for it.

define(`jabb', 10.2.3.4)

; The SOA record

SOA(a.example.com)
NS(ns1.example.com, ns2.example.com)

; We want the domain itself to have an A record, but we don't want a PTR
; record to be generated, hence DADDR instead of ADDR.

DADDR(jabb)

; Some hosts

H(jabberwock, jabb)
H(this-one-is-classless-reverse-delegated, 10.3.0.65)

undefine(`dnl')
H(dnl, jabb)
