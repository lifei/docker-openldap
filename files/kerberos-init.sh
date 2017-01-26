#!/usr/bin/env bash

mkdir /tmp/kerberos
cd /tmp/kerberos

cat > schema_convert.conf <<EOF
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/collective.schema
include /etc/ldap/schema/corba.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/duaconf.schema
include /etc/ldap/schema/dyngroup.schema
include /etc/ldap/schema/inetorgperson.schema
include /etc/ldap/schema/java.schema
include /etc/ldap/schema/misc.schema
include /etc/ldap/schema/nis.schema
include /etc/ldap/schema/openldap.schema
include /etc/ldap/schema/ppolicy.schema
include /etc/ldap/schema/kerberos.schema
EOF

mkdir ldif_output

slapcat -f schema_convert.conf -F ldif_output -n0 -s "cn={12}kerberos,cn=schema,cn=config" |\
sed 's/dn: cn={12}kerberos,cn=schema,cn=config/dn: cn=kerberos,cn=schema,cn=config/' |\
sed 's/cn: {12}kerberos/cn: kerberos/' |\
head -n -8 > kerberos.ldif

ldapadd -Q -Y EXTERNAL -H ldapi:/// -f kerberos.ldif
ldapmodify  -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange,krbPrincipalKey by self write by anonymous auth by dn="$ADMIN_DN" write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by self write by dn="$ADMIN_DN" write by * read
-
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF

rm -rf /tmp/kerberos
