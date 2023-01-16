#!/bin/bash
url="$1"

if [[ ! -d '/srv/yt/downloads' ]] ; then
  exit 1
fi

if [[ ! -d '/var/log/yt' ]] ; then
  exit 1
fi

mkdir downloads 2> /dev/null

_youtubedl='/usr/local/bin/youtube-dl'

name="$($_youtubedl --get-title ${url})"
mkdir "/srv/yt/downloads/$name"
folderPath="/srv/yt/downloads/$name"
filePath="$folderPath/$name.mp4"
date=$(date +'[%y/%m/%d %H:%M:%S]')

$_youtubedl "$url" -o "/srv/yt/downloads/$name/${name}.mp4"
$_youtubedl --get-description $1 > "$folderPath/description"

echo "Video $1 was downloaded."
echo "File path : $filePath"

mkdir /var/log/yt 2> /dev/null
logPath="/var/log/yt/download.log"

echo "$date Video $1 was downloaded. File path : $filePath" >> $logPath