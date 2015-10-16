FROM phusion/baseimage
MAINTAINER Li Fei "lifei.vip@outlook.com"
RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors.sohu.com\/ubuntu\//' /etc/apt/sources.list
RUN sed -i 's/deb-src/# deb-src/' /etc/apt/sources.list
RUN apt-get update

RUN echo 'slapd/root_password password password' | debconf-set-selections &&\
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils krb5-user sasl2-bin libsasl2-modules-gssapi-mit

RUN apt-get clean

RUN adduser openldap sasl

COPY files/kerberos.schema /etc/ldap/schema/kerberos.schema
COPY files/sssvlv_load.ldif /etc/ldap/sssvlv/sssvlv_load.ldif
COPY files/sssvlv_config.ldif /etc/ldap/sssvlv/sssvlv_config.ldif
COPY files/saslauthd /etc/default/saslauthd
COPY files/slapd.conf /etc/ldap/sasl2/slapd.conf
COPY files/openldap-init.sh /usr/local/bin/openldap-init.sh
COPY files/kerberos-init.sh /usr/local/bin/kerberos-init.sh
COPY files/krb5-init.sh /usr/local/bin/krb5-init.sh

COPY files/service/slapd-run /etc/service/slapd/run
ADD files/service/saslauthd-init.sh /etc/my_init.d/00_saslauthd_init.sh

RUN chmod a+x /usr/local/bin/*-init.sh /etc/service/slapd/run /etc/my_init.d/00_saslauthd_init.sh

EXPOSE 389
EXPOSE 636
