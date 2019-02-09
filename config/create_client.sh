#!/bin/bash

function generate_keys() {
    pushd $VPN_HOME

    echo Create keys for ${CLIENT_NAME}

    # Create key-pair and certificate
    echo -en "\n\n" | ${EASYRSA_HOME}/easyrsa gen-req ${CLIENT_NAME} nopass

    if [ -z "$PASSPHRASE_MODE" ]
    then
        echo -n Passphrase:
        read -s passphrase
        openssl rsa -aes256 -in $VPN_HOME/pki/private/${CLIENT_NAME}.key -out $VPN_HOME/pki/private/${CLIENT_NAME}.key -passout pass:$passphrase
    fi

    echo -en "yes\n\n" | ${EASYRSA_HOME}/easyrsa sign-req client ${CLIENT_NAME}

    popd
}

function create_ovpn() {
    rm -rf ${VPN_HOME}/ovpn/${CLIENT_NAME}.ovpn
    echo "
client
dev tun
proto udp
remote $(cat $VPN_HOME/hostname) 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo
key-direction 1
auth SHA256
<ca>
$(cat $VPN_HOME/pki/ca.crt)
</ca>
<cert>
$(cat $VPN_HOME/pki/issued/${CLIENT_NAME}.crt | sed -n '/-----BEGIN CERTIFICATE-----*/,/-----BEGIN CERTIFICATE-----/p')
</cert>
<key>
$(cat $VPN_HOME/pki/private/${CLIENT_NAME}.key)
</key>
<tls-auth>
$(cat $VPN_HOME/ta.key)
</tls-auth>
" >> ${VPN_HOME}/ovpn/${CLIENT_NAME}.ovpn
}

if [ -z "$1" ]
then
    echo "Please provide a client name"
    exit
fi

export CLIENT_NAME=$1
export PASSPHRASE_MODE=$2

if [ -f "${VPN_HOME}/ovpn/${CLIENT_NAME}.ovpn" ]
then
    echo "Client already exists!"
    exit
fi

mkdir -p ${VPN_HOME}/ovpn
generate_keys
create_ovpn
cat ${VPN_HOME}/ovpn/${CLIENT_NAME}.ovpn