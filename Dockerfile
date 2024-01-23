FROM alpine:3

ARG USER=rev

RUN apk add --no-cache \
  bash \
  openssh

RUN adduser -D -s /bin/ash ${USER} && \
  echo "${USER}:*" | chpasswd -e && \
  mkdir /home/${USER}/.ssh && \
  chown ${USER}:${USER} /home/${USER}/.ssh && \
  chmod 700 /home/${USER}/.ssh && \
  touch /home/${USER}/.ssh/authorized_keys && \
  chown ${USER}:${USER} /home/${USER}/.ssh/authorized_keys && \
  chmod 600 /home/${USER}/.ssh/authorized_keys

COPY sshd_config /etc/ssh/sshd_config

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
VOLUME [ "/etc/ssh-host-keys", "/etc/ssh-public-keys" ]

ENV SSH_HOST_RSA=""
ENV SSH_HOST_ECDSA=""
ENV SSH_HOST_ED25519=""

ENV SSH_PUBLIC_KEY=""

CMD ["bash", "/start.sh"]
