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
    export ASTERISK_RUN_GROUP=asterisk
fi

if [ -n "${ASTERISK_RUN_UID:-}" ]; then
    if [ ! $(getent passwd pbx) ]; then
        adduser --gecos "" --ingroup ${ASTERISK_RUN_GROUP} --no-create-home --disabled-password --disabled-login --uid ${ASTERISK_RUN_UID} pbx
    fi
    export ASTERISK_RUN_USER=pbx
    echo "Changing service UID to ${ASTERISK_RUN_UID}."
else
    export ASTERISK_RUN_USER=asterisk
fi

if [[ "$1" == asterisk* ]]; then
fi

exec "$@"