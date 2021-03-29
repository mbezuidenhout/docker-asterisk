#!/bin/bash
set -euo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ -n "${ASTERISK_RUN_GID:-}" ]; then
    if [ ! $(getent group pbx) ]; then
        addgroup --gid ${ASTERISK_RUN_GID} pbx
    fi
    export ASTERISK_RUN_GROUP=pbx
    echo "Changing service GID to ${ASTERISK_RUN_GID}."
else
    export ASTERISK_RUN_GROUP=dialout
fi

if [ -n "${ASTERISK_RUN_UID:-}" ]; then
    if [ ! $(getent passwd pbx) ]; then
        #adduser --gecos "" --ingroup ${ASTERISK_RUN_GROUP} --no-create-home --disabled-password --disabled-login --uid ${ASTERISK_RUN_UID} pbx
        adduser -g "" -G ${ASTERISK_RUN_GROUP} -H -D -s /bin/nologin -u ${ASTERISK_RUN_UID} pbx
        usermod -G audio pbx
        usermod -G dialout pbx
        find / -user asterisk -exec chown pbx '{}' \;
    fi
    export ASTERISK_RUN_USER=pbx
    echo "Changing service UID to ${ASTERISK_RUN_UID}."
else
    export ASTERISK_RUN_USER=asterisk
fi

# Starting postfix
if [ ! -e /etc/postfix/main.cf ]; then
    echo >&2 "Postfix config not found in /etc/postfix - copying default config now..."
    if [ -n "$(ls -A)" ]; then
        echo >&2 "WARNING: /etc/postfix is not empty! (copying anyhow)"
    fi
    sourceTarArgs=(
        --create
        --file -
        --directory /usr/src/postfix
    )	
    targetTarArgs=(
        --extract
        --file -
        --directory /etc/postfix
    )
    tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
    echo >&2 "Complete! Postfix default config has been successfully copied to /etc/postfix"
fi
echo "Starting Postfix"
/usr/sbin/postfix -c /etc/postfix start

if [ "$1" == 'asterisk' ]; then
    if [ ! -e asterisk.conf ]; then
        echo >&2 "Asterisk config not found in $PWD - copying default config now..."
        if [ -n "$(ls -A)" ]; then
            echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
        fi
        sourceTarArgs=(
            --create
            --file -
            --directory /usr/src/asterisk
            --owner "$ASTERISK_RUN_USER" --group "$ASTERISK_RUN_GROUP"
        )
        targetTarArgs=(
            --extract
            --file -
        )
        tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
        echo >&2 "Complete! Asterisk default config has been successfully copied to $PWD"
    fi
    exec asterisk -U ${ASTERISK_RUN_USER} -G ${ASTERISK_RUN_GROUP} -fvvv
fi

exec "$@"
