#!/bin/bash

# The script backs places the backup in the /srv/backup folder

[[ -d /srv/backup ]] || mkdir /srv/backup
dnf install tar -y
cd /var/www/tp5_nextcloud/
tar -czf /srv/backup/nextcloud_$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz themes/ data/ config/