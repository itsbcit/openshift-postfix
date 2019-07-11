if [ "$EUID" != "0" ];then
    echo 'This container must run as root :(' >&2
    exit 255
fi

[ -f "$CONFIGDIR"/aliases ] || cp /etc/aliases "$CONFIGDIR"/aliases
[ -f "$CONFIGDIR"/main.cf ] || tar zxf /postfix-config.tar.gz -C "$CONFIGDIR"

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

cp --dereference -r "$CONFIGDIR"/* /etc/postfix/

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFIGDIR}/.DOCKERIZE.env"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
for tmpl_file in $( find /etc/postfix -type f -name '*.tmpl' -not -path '*/\.git/*' ); do
    config_file="$( dirname -- "$tmpl_file" )/$( basename -- "$tmpl_file" .tmpl )"
    echo "dockerizing: ${tmpl_file}"
    echo "         =>  ${config_file}"
    dockerize -template "$tmpl_file":"$config_file" \
    && rm -f "$tmpl_file"
done

# generate aliases.db
newaliases

# process map files with postmap
if [ -e "${POSTMAP_LISTFILE}" ];then
    for postmap_file in $( cat ${POSTMAP_LISTFILE}); do postmap "$postmap_file"; done
fi
