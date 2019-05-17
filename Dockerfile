FROM bcit/centos:7

ENV CONFIGDIR /etc/postfix
ENV MAILSPOOLDIR /spool/mail
ENV QUEUEDIR /spool/postfix
ENV SECRETSDIR /etc/postfix-secrets
ENV DATADIR /data/postfix

LABEL maintainer="jesse_weisner@bcit.ca"
LABEL version="3.4.4"

RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
    http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-gf.el7

RUN yum -y --enablerepo=gf-plus --enablerepo=gf-testing --setopt tsflags=nodocs --setopt timeout=5 install \
    postfix3-3.4.4 \
    postfix3-ldap-3.4.4 \
    postfix3-pcre-3.4.4

RUN postconf \
    inet_interfaces="all" \
    inet_protocols="ipv4" \
    alias_database=hash:/etc/postfix/aliases \
    alias_maps=hash:/etc/postfix/aliases \
    mail_spool_directory=/spool/mail \
    queue_directory=/spool/postfix \
    data_directory=/data/postfix

RUN tar czf /postfix-config.tar.gz -C /etc/postfix . \
 && rm -rf /etc/postfix/* \
 && tar czf /postfix-spool.tar.gz -C /var/spool/postfix .

RUN mkdir \
    /etc/postfix-secrets \
    /spool \
    /data

RUN chown 0:0 /spool \
              /data \
              /etc/postfix \
              /etc/postfix-secrets \
 && chmod 775 /spool \
              /data \
              /etc/postfix \
              /etc/postfix-secrets

VOLUME /spool
VOLUME /data
VOLUME /etc/postfix
VOLUME /etc/postfix-secrets

EXPOSE 25 465 587

COPY 70-postfix-config.sh /docker-entrypoint.d/70-postfix-config.sh

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
CMD ["postfix","start-fg"]
