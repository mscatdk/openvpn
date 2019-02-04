#!/bin/bash

function revoke_certificate() {
    pushd $VPN_HOME

    echo Revoke client: ${CLIENT_NAME}

    echo -en "yes\n\n" | ${EASYRSA_HOME}/easyrsa revoke ${CLIENT_NAME}
    echo "Generating the Certificate Revocation List :"
    ${EASYRSA_HOME}/easyrsa gen-crl
    cp ${VPN_HOME}/pki/crl.pem ${APP_HOME}/crl.pem
    chmod 644 ${APP_HOME}/crl.pem

    popd
}

if [ -z "$1" ]
then
    echo "Please provide a client name"
    exit
fi

export CLIENT_NAME=$1

revoke_certificate