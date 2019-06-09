#
# Asterisk Dockerfile
#

FROM ubuntu:latest
LABEL maintainer="Marius Bezuidenhout <marius.bezuidenhout@gmail.com>"

ENV TZ Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&\
    apt-get update &&\
    apt-get install --no-install-recommends --assume-yes --quiet \
        asterisk asterisk-config asterisk-core-sounds-en asterisk-core-sounds-en-gsm asterisk-modules asterisk-moh-opsound-gsm asterisk-voicemail \
        ca-certificates curl git systemd-cron &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    mv /etc/asterisk /usr/src &&\
    mkdir /etc/asterisk &&\
    ldconfig

WORKDIR /etc/asterisk
VOLUME ["/etc/asterisk"]
EXPOSE 5060/udp 5060/tcp 16384/udp 16385/udp 16386/udp 16387/udp 16388/udp 16389/udp 16390/udp 16391/udp 16392/udp 16393/udp 16394/udp

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["asterisk"]
