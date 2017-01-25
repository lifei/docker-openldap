#!/usr/bin/env bash

mkdir /etc/ldap/ssl/
openssl req -new -x509 -nodes -out /etc/ldap/ssl/slapd.cert -keyout /etc/ldap/ssl/slapd.key -days 365
chown root:openldap /etc/ldap/ssl/slapd.key
chmod 640 /etc/ldap/ssl/slapd.key

ldapmodify  -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=config
changetype: modify
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/ssl/slapd.cert
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/ssl/slapd.key
EOF

ldapadd -Q -Y EXTERNAL -H ldapi:/// <<EOF
version: 1
changeType: add
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {1}mdb
olcDbDirectory: /var/lib/ldap
olcSuffix: $DOMAIN_DN
olcAccess: {0}to attrs=userPassword,shadowLastChange by self write by anonymous auth by dn="$ADMIN_DN" write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by self write by dn="$ADMIN_DN" write by * read
olcLastMod: TRUE
olcRootDN: $ADMIN_DN
olcRootPW: $ADMIN_PW
olcDbCheckpoint: 512 30
olcDbIndex: objectClass eq
olcLimits: dn.exact="$ADMIN_DN" size=unlimited
EOF


ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/ldap/sssvlv/sssvlv_load.ldif
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/ldap/sssvlv/sssvlv_config.ldif

ldapadd -x -D $ADMIN_DN -w $ADMIN_PW <<EOF
dn: $DOMAIN_DN
dc: $NAME
objectClass: dcObject
objectClass: organizationalUnit
ou: $NAME
EOF
