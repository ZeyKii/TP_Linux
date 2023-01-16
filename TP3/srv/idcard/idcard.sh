#!/bin/bash
name=$(hostnamectl hostname)
source /etc/os-release
version=$(uname -v)
ips=$(ip -4 a  | grep inet | tail -n1 | tr -s ' ' | cut -d' ' -f3)
freeram=$(free --mega -t | grep Total: | tr -s ' ' | cut -d' ' -f4)
totalram=$(free --mega -t | grep Total: | tr -s ' ' | cut -d' ' -f2)
totaldisk=$(df -a | grep /dev/sda1 | tr -s ' ' | cut -d' ' -f4)

echo Machine name : $name

echo OS $PRETTY_NAME and kernel version is $version

echo IP : $ips

echo RAM : $freeram memory available on $totalram total memory

echo Disk : $totaldisk space left

echo Top 5 processes by RAM usage :
while read super_line; do
  echo "  - $(echo $super_line)"
done <<< "$(ps -eo %mem=,pid=,cmd= --sort -%mem | head -n5 | tr -s ' ')"

echo Listening ports :
while read super_line; do
  num="$(echo $super_line | cut -d' ' -f5 | cut -d':' -f2)"
  protocole="$(echo $super_line | cut -d' ' -f1)"
  ssname="$(echo $super_line | cut -d' ' -f7 | cut -d'"' -f2)"
  echo "  - ${num} ${protocole} : ${ssname}"
done <<< "$(ss -t -u -l -n -p -4 -H | tr -s ' ')"

curl -o cat https://cataas.com/cat
cat_type="$(file cat)"
if [[ $cat_type == *JPEG* ]]; then
  mv cat cat.jpg;
  echo "Here is your random cat : ./cat.jpg"
elif [[ $cat_type == *PNG* ]]; then
  mv cat cat.png;
  echo "Here is your random cat : ./cat.png"
elif [[ $cat_type == *GIF* ]]; then
  mv cat cat.gif;
  echo "Here is your random cat : ./cat.gif"
else
  echo "the file format is not supported";
fi