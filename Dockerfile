FROM bcit/centos:7
LABEL maintainer="jesse_weisner@bcit.ca, Juraj Ontkanin"
LABEL postfix_version="3.5.7"
LABEL build_id="1600202035"

ENV DOCKERIZE_ENV production

ENV CONFIGDIR /config
ENV CONFIGDIR_SSL /config-ssl

ENV SPOOLDIR /spool
ENV DATADIR /data

ENV POSTMAP_LISTFILE /etc/postfix/postmap-files

RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
    http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-gf.el7

RUN yum -y --enablerepo=gf-plus --enablerepo=gf-testing --setopt tsflags=nodocs --setopt timeout=5 install \
    postfix3-3.5.7 \
    postfix3-ldap-3.5.7 \
    postfix3-pcre-3.5.7 \
    cyrus-sasl \
    cyrus-sasl-plain

RUN mkdir -p \
    "${CONFIGDIR}" \
    "${CONFIGDIR_SSL}"

RUN postconf \
    inet_interfaces="all" \
    inet_protocols="ipv4" \
    alias_database=hash:/etc/postfix/aliases \
    alias_maps=hash:/etc/postfix/aliases \
    mail_spool_directory="${SPOOLDIR}/mail" \
    queue_directory="${SPOOLDIR}/postfix" \
    data_directory="${DATADIR}/postfix"

## Configuration: /etc/postfix
RUN cp --dereference -r /etc/postfix/* "${CONFIGDIR}"/ \
 && rm -rf /etc/postfix \
 && mkdir -p /etc/postfix \
 && chown -R 0:0 /etc/postfix \
 && chmod -R 755 /etc/postfix

## Certificates
RUN rm -rf /etc/ssl/postfix \
 && mkdir -p /etc/ssl/postfix \
 && chown 0:0 /etc/ssl/postfix \
 && chmod 770 /etc/ssl/postfix

## Spool & Data
RUN tar czf /postfix-spool.tar.gz -C /var/spool/postfix . \
 && mkdir -p \
    "$SPOOLDIR" \
    "$DATADIR" \
 && chown 0:0 \
    "$SPOOLDIR" \
    "$DATADIR" \
 && chmod 775 \
    "$SPOOLDIR" \
    "$DATADIR"

VOLUME /etc/postfix
VOLUME "$SPOOLDIR"
VOLUME "$DATADIR"

EXPOSE 25 465 587

COPY 70-postfix-config.sh /docker-entrypoint.d/70-postfix-config.sh

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
CMD ["postfix","start-fg"]
