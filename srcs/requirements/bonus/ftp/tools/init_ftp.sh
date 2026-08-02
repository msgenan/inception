#!/bin/bash
set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)
FTP_USERNAME="${FTP_USER:-ftpuser}"

if ! id "${FTP_USERNAME}" &>/dev/null; then
    useradd -d /var/www/html -s /bin/bash "${FTP_USERNAME}"
    echo "${FTP_USERNAME}:${FTP_PASSWORD}" | chpasswd
fi

chown -R "${FTP_USERNAME}":"${FTP_USERNAME}" /var/www/html

mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf
