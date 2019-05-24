#
# Asterisk Dockerfile
#

FROM ubuntu:latest
MAINTAINER Marius Bezuidenhout "marius.bezuidenhout@gmail.com"

RUN apt-get update &&\
    apt-get install --no-install-recommends --assume-yes --quiet \
        asterisk asterisk-config asterisk-core-sounds-en asterisk-core-sounds-en-gsm asterisk-modules asterisk-moh-opsound-gsm asterisk-voicemail \
        ca-certificates curl git systemd-cron &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    ldconfig

EXPOSE 5060/udp 5060/tcp

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["asterisk"]
