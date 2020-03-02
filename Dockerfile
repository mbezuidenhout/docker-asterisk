#
# Asterisk Dockerfile
#

FROM alpine:3.8.4
LABEL maintainer="Marius Bezuidenhout <marius.bezuidenhout@gmail.com>"

ENV TZ Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&\
    apk add --no-cache shadow asterisk ca-certificates curl bash tar asterisk-sample-config asterisk-sounds-en asterisk-sounds-moh postfix mailx cyrus-sasl &&\
    rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/* &&\
    rm -f /etc/init.d/asterisk &&\
    mkdir /usr/src && mv /etc/asterisk /usr/src && mv /etc/postfix /usr/src &&\
    mkdir /etc/asterisk && mkdir /etc/postfix

WORKDIR /etc/asterisk
VOLUME ["/etc/asterisk"]
EXPOSE 5060/udp 5060/tcp 6060/udp 6060/tcp 16384/udp 16385/udp 16386/udp 16387/udp 16388/udp 16389/udp 16390/udp 16391/udp 16392/udp 16393/udp 16394/udp

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["asterisk"]
