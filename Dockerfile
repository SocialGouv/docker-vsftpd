ARG DEBIAN_VERSION=11

FROM debian:$DEBIAN_VERSION
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
	vsftpd \
	ca-certificates \
	db-util \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1001 vsftpd && useradd -rm -d /home/vsftpd -s /bin/bash -g vsftpd -G sudo -u 1001 vsftpd

ENV FTP_USER admin
ENV FTP_PASS admin
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
	&& chown /etc/vsftpd.d
RUN chown -R vsftpd:vsftpd /home/vsftpd/
RUN chown -R vsftpd:vsftpd /etc/vsftpd/
RUN touch /etc/vsftpd.key \
	&& touch /etc/vsftpd.pem \
	&& chown vsftpd:vsftpd /etc/vsftpd.key \
	&& chown vsftpd:vsftpd /etc/vsftpd.pem

USER 1001
CMD ["/usr/sbin/run-vsftpd.sh"]

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh
