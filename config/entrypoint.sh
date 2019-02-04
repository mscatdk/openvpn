#!/bin/bash

function generate_keys() {
    pushd $VPN_HOME
    # Create CA
    ${EASYRSA_HOME}/easyrsa init-pki
    echo -en "\n\n" | ${EASYRSA_HOME}/easyrsa build-ca nopass

    # Create server key-pair
    echo -en "\n\n" | ${EASYRSA_HOME}/easyrsa gen-req server nopass
    echo -en "yes\n\n" | ${EASYRSA_HOME}/easyrsa sign-req server server

    # Create Diffie Hellman parameter used for key exchange
    ${EASYRSA_HOME}/easyrsa gen-dh

    # Create shared key used to establish a "HMAC firewall" to help block DoS attacks and UDP port flooding.
    openvpn --genkey --secret ${VPN_HOME}/ta.key

    popd
}

function copyKeys() {
    cp ${VPN_HOME}/pki/ca.crt ${APP_HOME}/public/ca.crt

    cp ${VPN_HOME}/pki/private/server.key ${APP_HOME}/secret/server.key
    cp ${VPN_HOME}/pki/issued/server.crt ${APP_HOME}/public/server.crt

    cp ${VPN_HOME}/pki/dh.pem ${APP_HOME}/secret/dh.pem

    cp ${VPN_HOME}/ta.key ${APP_HOME}/secret/ta.key
}

function create_interface() {
    # Create tun interface
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
}

function update_iptables() {
    iptables -t nat -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
}

function start_openvpn_server() {
    # Start the openvpn server
    openvpn --config /etc/openvpn/server.conf --client-config-dir /etc/openvpn/clients
}

if [ ! -d ${VPN_HOME}/pki ]; then
   generate_keys
fi

copyKeys

if [ ! -c /dev/net/tun ]; then
   create_interface
fi

if [ ! -z "$OPENVPN_HOSTNAME" ]; then
    echo setting hostname to: $OPENVPN_HOSTNAME
    echo $OPENVPN_HOSTNAME > ${VPN_HOME}/hostname
fi

if [ ! -f ${VPN_HOME}/hostname ]; then
    echo "OPENVPN_HOSTNAME wasn't set; hence, localhost is used"
    echo localhost > ${VPN_HOME}/hostname
fi

update_iptables

start_openvpn_server