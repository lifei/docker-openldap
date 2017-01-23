FROM phusion/baseimage
MAINTAINER lifei "lifei.vip@outlook.com"
COPY files /tmp/openldap
RUN env bash /tmp/openldap/install.sh
EXPOSE 389
EXPOSE 636
