#!/bin/bash

if [ ! -d "/var/log/yt" ]; then
        echo "Please create the folder /var/log/yt"
        exit 1
fi

mkdir /srv/yt/downloads
touch /srv/yt/downloader

while :
do
        line=$(head -n 1 /srv/yt/downloader)
        if [ ! -z "$line" ]; then
                sed -i '1d' /srv/yt/downloader
                url="$line"
                title=$(youtube-dl --get-title "$url")
                folderPath="/srv/yt/downloads/$title"
                filePath="$folderPath/$title.mp4"
                date=$(date +'[%y/%m/%d %H:%M:%S]')
                youtube-dl "$url" -o "$filePath"> /dev/null
                youtube-dl --get-description "$url" > "$folderPath/description"
                logPath="/var/log/yt/download.log"
                echo "$date Video $url was downloaded. File path : $filePath" >> "$logPath"
        fi
done