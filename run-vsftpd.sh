#!/bin/bash

set -e

openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /etc/vsftpd.key -out /etc/vsftpd.pem -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" 2>/dev/null

mkdir -p "/home/vsftpd/${FTP_USER}"
echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db


echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=${PASV_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf
echo "port_promiscuous=${PORT_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf

echo "## custom variables from /etc/vsftpd.d" >> /etc/vsftpd/vsftpd.conf

if [ -e /etc/vsftpd.d/* ]; then
	cat /etc/vsftpd.d/* >> /etc/vsftpd/vsftpd.conf
fi

autoclean-logs.sh &

echo "starting vsftpd server"
vsftpd /etc/vsftpd/vsftpd.conf

exec tail -f /var/log/vsftpd.log