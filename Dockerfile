FROM alpine:latest

ENV APP_HOME=/etc/openvpn
ENV VPN_HOME=/home/vpn
ENV EASYRSA_HOME=/usr/share/easy-rsa

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update bash iptables openvpn easy-rsa openvpn-auth-pam && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* && \
    adduser -D -u 1000 vpn

COPY config/ ${APP_HOME}
COPY config/vars ${EASYRSA_HOME}

RUN mkdir ${APP_HOME}/clients && \
    mkdir ${APP_HOME}/secret && \
    mkdir ${APP_HOME}/public && \
    chmod +x ${APP_HOME}/*.sh

VOLUME ["/home/vpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn

CMD ["./entrypoint.sh"]