#!/bin/bash

function revoke_certificate() {
    pushd $VPN_HOME

    echo Revoke client: ${CLIENT_NAME}

    set -e
    echo -en "yes\n\n" | ${EASYRSA_HOME}/easyrsa revoke ${CLIENT_NAME}
    echo "Generating the Certificate Revocation List :"
    ${EASYRSA_HOME}/easyrsa gen-crl
    chmod 644 ${VPN_HOME}/pki/crl.pem
    set +e
    popd
}

if [ -z "$1" ]
then
    echo "Please provide a client name"
    exit
fi

export CLIENT_NAME=$1

revoke_certificate