#!/bin/bash

send_msg(){
  NL="%0A"
  URL="https://api.telegram.org/bot${TGMN_TOKEN}/sendMessage"
  PARSE_MODE="HTML"

  myName=$(hostname)
  myOS=$(hostnamectl | grep System | cut -d':' -f2)
  myKernel=$(hostnamectl | grep Kernel | awk '{ print $2,$3 }')
  nowTime=$(date | awk '{ print $5,$6 }')
  myAddress=$(nslookup localhost | awk NR\ ==\ 2\{print\ \$2\})
  inetAddr=$(ifconfig | awk '{ if ($1 == "inet" ) print $2 }' | tr -s '\r\n' ' ')
  publicIp=$(wget -t 1 -qO- ipinfo.io/ip)

  msg="🖥 $myName server is running <b>[up]</b>$NL"
  msg="$msg<b>OS:</b> $myOS/$myKernel$NL"
  msg="$msg<b>Server time:</b> $nowTime$NL"
  msg="$msg<b>Server address:</b> $myAddress$NL"
  msg="$msg<b>Inet addr:</b> $inetAddr$NL"
  msg="$msg<b>Public IP:</b> $publicIp$NL"

  MESSAGE=$(echo ${msg// /%20})

  /usr/bin/curl -s -X POST $URL -d chat_id=${TGMN_CHAT_ID} -d text=${MESSAGE} -d parse_mode=${PARSE_MODE} > /dev/null 2>&1
}

TGMN_TOKEN=$(cat /opt/TgmNotifier/startup-notif.conf | grep Token | cut -d' ' -f2)
TGMN_CHAT_ID=$(cat /opt/TgmNotifier/startup-notif.conf | grep Chat | cut -d' ' -f2)

if [ -z ${TGMN_TOKEN} ]; then
  echo "No token or chat_id"
else
  send_msg
fi
