# openvpn

This is a dockerization of OpenVPN for multiple platforms. Key-pairs, keys and certificates are generated in the folder /home/vpn on startup in case in the folder /home/vpn/pki doesn't already exist. The generation can take a long time on devices with low proccesing power like a Raspberry PI's. The /home/vpn folder should be mapped to a persistant volume to preserve the generated keys in case of e.g. restart.

## Build

The container is build using the following command

```bash
docker build . -t mscatdk/openvpn
```

## Running OpenVPN

The container can be started as follows

```bash
docker run -d --rm --cap-add=NET_ADMIN -v /etc/openvpn:/home/vpn -p 1194:1194/udp -e OPENVPN_HOSTNAME="openvpn.local" mscatdk/openvpn
```

The environment varibale OPENVPN_HOSTNAME and the volume should be adjusted to your needs.

### Generate Client OVPN

You can generated the needed keys for client by running the following command

```bash
# Comannd output and OVPN file content will be printed to screen
docker run -it --rm -v /etc/openvpn:/home/vpn mscatdk/openvpn /etc/openvpn/create_client.sh [Client name]

# Save the OVPN directly to file
docker run -it --rm -v /etc/openvpn:/home/vpn mscatdk/openvpn /etc/openvpn/create_client.sh [Client name] | sed -n '/^client*/,/<\/tls-auth>/p' > [Client name].ovpn

# Generate ovpn without password
docker run -it --rm -v /etc/openvpn:/home/vpn mscatdk/openvpn /etc/openvpn/create_client.sh [Client name] nopass
```

### Revoke Client Access

You can revoke client access by running the following command

```bash
docker run -it --rm -v /etc/openvpn:/home/vpn mscatdk/openvpn /etc/openvpn/revoke_client.sh [Client name]
```

## Testing

The container has been manually tested on x86 and ARM (Raspberry PI).
