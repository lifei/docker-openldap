#!/usr/bin/env bash
cat > /etc/krb5.conf<<EOF
[logging]
 default = FILE:/var/log/krb5libs.log

[libdefaults]
 default_realm = $KRB5REALM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 $KRB5REALM = {
  kdc = $KDC_ADDRESS
  admin_server = $KDC_ADDRESS
  default_domain = $DOMAIN_REALM
 }

[domain_realm]
 .$DOMAIN_REALM = $KRB5REALM
 $DOMAIN_REALM = $KRB5REALM
EOF

kadmin -q "ank -randkey host/$HOSTNAME"
kadmin -q "ank -randkey ldap/$HOSTNAME"
kadmin -q "ktadd host/$HOSTNAME"
kadmin -q "ktadd ldap/$HOSTNAME"
