#! /usr/bin/env bash

USER=rev
SSH_KEY_DIR="/etc/ssh-host-keys"
PUB_KEY_DIR="/etc/ssh-public-keys"

# use user-provided host keys in this order: ENVIROMENT VARIABLES, FILES in volume ${SSH_KEY_DIR}, GENERATE KEYS
if [ -n "$SSH_HOST_RSA" ]; then
	echo "$SSH_HOST_RSA" >/etc/ssh/ssh_host_rsa_key
	chmod 600 /etc/ssh/ssh_host_rsa_key
elif [[ -f "${SSH_KEY_DIR}/ssh_host_rsa_key" ]]; then
	cp "${SSH_KEY_DIR}/ssh_host_rsa_key" /etc/ssh/ssh_host_rsa_key
	chmod 600 /etc/ssh/ssh_host_rsa_key
else
	ssh-keygen -t rsa -b 4096 -f "${SSH_KEY_DIR}/ssh_host_rsa_key" -N ''
	chmod 600 "${SSH_KEY_DIR}/ssh_host_rsa_key"
	cp "${SSH_KEY_DIR}/ssh_host_rsa_key" /etc/ssh/ssh_host_rsa_key
fi

if [ -n "$SSH_HOST_ECDSA" ]; then
	echo "$SSH_HOST_ECDSA" >/etc/ssh/ssh_host_ecdsa_key
	chmod 600 /etc/ssh/ssh_host_ecdsa_key
elif [[ -f "${SSH_KEY_DIR}/ssh_host_ecdsa_key" ]]; then
	cp "${SSH_KEY_DIR}/ssh_host_ecdsa_key" /etc/ssh/ssh_host_ecdsa_key
	chmod 600 /etc/ssh/ssh_host_ecdsa_key
else
	ssh-keygen -t ecdsa -b 521 -f "${SSH_KEY_DIR}/ssh_host_ecdsa_key" -N ''
	chmod 600 "${SSH_KEY_DIR}/ssh_host_ecdsa_key"
	cp "${SSH_KEY_DIR}/ssh_host_ecdsa_key" /etc/ssh/ssh_host_ecdsa_key
fi

if [ -n "$SSH_HOST_ED25519" ]; then
	echo "$SSH_HOST_ED25519" >/etc/ssh/ssh_host_ed25519_key
	chmod 600 /etc/ssh/ssh_host_ed25519_key
elif [[ -f "${SSH_KEY_DIR}/ssh_host_ed25519_key" ]]; then
	cp "${SSH_KEY_DIR}/ssh_host_ed25519_key" /etc/ssh/ssh_host_ed25519_key
	chmod 600 /etc/ssh/ssh_host_ed25519_key
else
	ssh-keygen -t ed25519 -f "${SSH_KEY_DIR}/ssh_host_ed25519_key" -N ''
	chmod 600 "${SSH_KEY_DIR}/ssh_host_ed25519_key"
	cp "${SSH_KEY_DIR}/ssh_host_ed25519_key" /etc/ssh/ssh_host_ed25519_key
fi

# use user-provided public keys in environment variables
if [ -n "$SSH_PUBLIC_KEY" ]; then
	echo "$SSH_PUBLIC_KEY" >>/home/${USER}/.ssh/authorized_keys
fi

i=1
while true; do
	key_var="SSH_PUBLIC_KEY_$i"
	if [ -n "${!key_var}" ]; then
		echo "${!key_var}" >>/home/${USER}/.ssh/authorized_keys
		i=$((i + 1))
	else
		break
	fi
done

# use user-provided authorized_keys file in volume ${PUB_KEY_DIR}
if [ -f "${PUB_KEY_DIR}/authorized_keys" ]; then
	ln -s "${PUB_KEY_DIR}/authorized_keys" /home/${USER}/.ssh/authorized_keys2
fi

# start the ssh server
/usr/sbin/sshd -D -e
