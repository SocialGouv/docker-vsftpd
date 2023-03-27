ARG DEBIAN_VERSION=11

FROM debian:$DEBIAN_VERSION
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
	vsftpd \
	ca-certificates \
	db-util \
	openssl \
	openssh-server \
	libpam-pwdfile \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1001 vsftpd && useradd -rm -d /home/vsftpd -s /bin/bash -g vsftpd -G sudo -u 1001 vsftpd

ENV FTP_USER admin
ENV FTP_PASS admin
ENV PASV_ADDRESS 127.0.0.1
ENV PASV_ADDR_RESOLVE NO
ENV PASV_ENABLE YES
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV FILE_OPEN_MODE 0666
ENV LOCAL_UMASK 077
ENV PASV_PROMISCUOUS NO
ENV PORT_PROMISCUOUS NO

RUN mkdir -p /home/vsftpd/
RUN mkdir -p /etc/vsftpd.d/ \
	&& chown vsftpd:vsftpd /etc/vsftpd.d
RUN chown -R vsftpd:vsftpd /home/vsftpd/
RUN touch /etc/vsftpd.key \
	&& touch /etc/vsftpd.pem \
	&& touch /var/log/vsftpd.log \
	&& chown vsftpd:vsftpd /etc/vsftpd.key \
	&& chown vsftpd:vsftpd /etc/vsftpd.pem \
	&& chown vsftpd:vsftpd /var/log/vsftpd.log

CMD ["/usr/local/bin/run-vsftpd.sh"]

COPY --chown=vsftpd:vsftpd vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/local/bin/
COPY autoclean-logs.sh /usr/local/bin/

USER 1001
