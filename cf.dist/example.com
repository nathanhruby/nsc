; Domain configuration file for example.com

; The SOA record

SOA(example.com)

; Other records for the domain itself (NSC remembers the name as it
; does with host names): name servers and mail exchangers with different
; priorities.

NS(ns1.example.com, ns2.example.com)
MX(0 mail.example.com, 10 smtp.example.net)

; The domain also has its own service record for Jabber, handled by the `mail' machine

SRV(jabber, tcp, 0, 1, 5269, mail)
SRV(xmpp-server, tcp, 0, 1, 5269, mail)
SRV(xmpp-client, tcp, 0, 1, 5222, mail)

; Responsible person record (e-mail and reference to textual contact information)

RP(admin.example.com, text)

; A couple of hosts

H(ns1, 10.0.0.1)
H(ns2, 10.1.0.1)
H(mail, 10.0.0.2)

; A web server with several aliases and MX records

H(www, 10.0.0.3)
ALIAS(fairytales, scifi, horror)
MX(0 mail.example.com)

; TXT record

H(text)
TXT(Once upon a midnight dreary)
TXT(When I pondered weak and weary)

; A subdomain called a.example.com

D(a)
NS(ns1.example.com, ns2.example.com)

; Another subdomain (b.example.com), but this time one of the nameservers
; is inside, so we need to specify a glue record

D(b)
NS(ns.b.example.com, ns1.example.com, ns2.example.com)
GLUE(ns.b.example.com, 10.1.0.2)

; And finally a subdomain for testing IPv6

D(ip6)
NS(ns1.example.com, ns2.example.com)

; That's all, you will find the more advanced examples in cf/a.example.com
