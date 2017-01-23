#!/usr/bin/env bash

set -e
umask 022

sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors.aliyun.com\/ubuntu\//' /etc/apt/sources.list
sed -i 's/deb-src/# deb-src/' /etc/apt/sources.list
apt-get update

echo 'slapd/root_password password password' | debconf-set-selections &&\
echo 'slapd/root_password_again password password' | debconf-set-selections && \
DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils krb5-user sasl2-bin libsasl2-modules-gssapi-mit && \
apt-get clean

mkdir -p /etc/service/slapd /etc/ldap/sssvlv

TMP_PATH=/tmp/openldap

cp ${TMP_PATH}/kerberos.schema /etc/ldap/schema/kerberos.schema
cp ${TMP_PATH}/sssvlv_load.ldif /etc/ldap/sssvlv/sssvlv_load.ldif
cp ${TMP_PATH}/sssvlv_config.ldif /etc/ldap/sssvlv/sssvlv_config.ldif
cp ${TMP_PATH}/saslauthd /etc/default/saslauthd
cp ${TMP_PATH}/slapd.conf /etc/ldap/sasl2/slapd.conf
cp ${TMP_PATH}/openldap-init.sh /usr/local/bin/openldap-init.sh
cp ${TMP_PATH}/kerberos-init.sh /usr/local/bin/kerberos-init.sh
cp ${TMP_PATH}/krb5-init.sh /usr/local/bin/krb5-init.sh
cp ${TMP_PATH}/service/slapd-run /etc/service/slapd/run
cp ${TMP_PATH}/service/saslauthd-init.sh /etc/my_init.d/00_saslauthd_init.sh

chmod a+x /usr/local/bin/*-init.sh /etc/service/slapd/run /etc/my_init.d/00_saslauthd_init.sh

adduser openldap sasl

rm -f "/etc/ldap/slapd.d/cn=config/olcDatabase={1}hdb.ldif" /var/lib/ldap/*
rm -rf ${TMP_PATH}