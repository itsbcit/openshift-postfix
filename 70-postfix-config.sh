if [ "$EUID" != "0" ]; then
    echo 'This container must run as root :(' >&2
    exit 255
fi

mkdir -p "${SPOOLDIR}/mail"
chown postfix:postfix "${SPOOLDIR}/mail"
chmod 700 "${SPOOLDIR}/mail"

if [ ! -d "${SPOOLDIR}/postfix" ]; then
    mkdir -p "${SPOOLDIR}/postfix"
    tar zxf /postfix-spool.tar.gz -C "${SPOOLDIR}/postfix"
fi
chown root:postfix "${SPOOLDIR}/postfix"
chmod 750 "${SPOOLDIR}/postfix"

mkdir -p "${DATADIR}/postfix"
chown postfix:postfix "${DATADIR}/postfix"
chmod 700 "${DATADIR}/postfix"

[ -f "$CONFIGDIR"/aliases ] || cp /etc/aliases "$CONFIGDIR"/aliases

stat "${CONFIGDIR}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR}"/* /etc/postfix/

stat "${CONFIGDIR_SSL}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR_SSL}"/* /etc/ssl/postfix/

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFIGDIR}/.DOCKERIZE.env"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
echo "DOCKERIZE_ENV: ${DOCKERIZE_ENV}"
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
