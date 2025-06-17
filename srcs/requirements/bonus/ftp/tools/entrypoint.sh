#!/bin/bash

# Fix ownership
ADMIN_PASSWORD=$(cat /run/secrets/ADMIN_PASSWORD)
useradd -m -d /home/$FTPUSER -s /bin/bash $FTPUSER
echo "$FTPUSER:$ADMIN_PASSWORD" | chpasswd
chown -R $FTPUSER:$FTPUSER /home/$FTPUSER

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd.conf