; Domain configuration file for ip6.example.com

SOA(ip6.example.com)
NS(ns1.example.com, ns2.example.com)

; This host has both IPv4 and IPv6 addresses

H(blackbox, 10.1.0.99, fec0:1234::0123:4567:89ab:cdef, fec0:1235::1234, fec0:1234::f:e:d:c)
