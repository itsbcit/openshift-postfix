if [ "$EUID" != "0" ];then
    echo 'This container must run as root :(' >&2
    exit 255
fi

[ -f ${CONFIGDIR}/aliases ] || cp /etc/aliases ${CONFIGDIR}/aliases
[ -f ${CONFIGDIR}/main.cf ] || tar zxf /postfix-config.tar.gz -C ${CONFIGDIR}

if [ ! -d ${MAILSPOOLDIR} ];then
    mkdir -p ${MAILSPOOLDIR}
    chown postfix:postfix ${MAILSPOOLDIR}
    chmod 700 ${MAILSPOOLDIR}
fi

if [ ! -d ${QUEUEDIR} ];then
    mkdir -p ${QUEUEDIR}
    chown postfix:postfix ${QUEUEDIR}
    chmod 700 ${QUEUEDIR}
    tar zxf /postfix-spool.tar.gz -C ${QUEUEDIR}
fi

if [ ! -d ${DATADIR} ];then
    mkdir -p ${DATADIR}
    chown postfix:postfix ${DATADIR}
    chmod 700 ${DATADIR}
fi
