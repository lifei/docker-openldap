#!/usr/bin/env bash

ldapadd -Q -Y EXTERNAL -H ldapi:/// <<EOF
version: 1
changeType: add
dn: olcDatabase=hdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcHdbConfig
olcDatabase: {2}hdb
olcDbDirectory: /var/lib/ldap
olcSuffix: $DOMAIN_DN
olcAccess: {0}to attrs=userPassword,shadowLastChange by self write by anonymous auth by dn="$ADMIN_DN" write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by self write by dn="$ADMIN_DN" write by * read
olcLastMod: TRUE
olcRootDN: $ADMIN_DN
olcRootPW: $ADMIN_PW
olcDbCheckpoint: 512 30
olcDbConfig: {0}set_cachesize 0 2097152 0
olcDbConfig: {1}set_lk_max_objects 1500
olcDbConfig: {2}set_lk_max_locks 1500
olcDbConfig: {3}set_lk_max_lockers 1500
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