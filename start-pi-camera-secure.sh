#!/bin/bash

# Make sure the NODE_MEDIA_PRIVATE_KEY environment variable is set
if [ -z ${NODE_MEDIA_PRIVATE_KEY+x} ]; then
  echo "Make sure you set the NODE_MEDIA_PRIVATE_KEY is set";
  exit -1;
fi

PI_IP_ADDRESS="192.168.1.71"
SERVER_IP_ADDRESS="192.168.1.71"
NODE_MEDIA_EXPIRATION=$(($(date +%s) * 2))
NODE_MEDIA_ROUTE="/live/monitor"
NODE_MEDIA_HASH_VALUE=$(echo -n "$NODE_MEDIA_ROUTE-$NODE_MEDIA_EXPIRATION-$NODE_MEDIA_PRIVATE_KEY" | md5sum | awk '{print $1}')
NODE_MEDIA_SIGNED="?sign=$NODE_MEDIA_EXPIRATION-$NODE_MEDIA_HASH_VALUE"

local=false
cloud=false

while getopts lci: option
do
case "${option}"
in
l) local=true;;
c) cloud=true;;
i) SERVER_IP_ADDRESS=${OPTARG};;
esac
done

killProcesses() {
  killall picam --wait;
  killall ffmpeg --wait;
}
sendLocalWSLink() {
  wsURL="ws://$PI_IP_ADDRESS:8000$NODE_MEDIA_ROUTE.flv$NODE_MEDIA_SIGNED";
  curl --request POST \
  --header "Content-Type: application/json" \
  -d "{\"wsURL\": \"$wsURL\"}" \
  "http://127.0.0.1:3333/video-url"
}
sendCloudWSLink() {
  wsURL="wss://$SERVER_IP_ADDRESS:8443$NODE_MEDIA_ROUTE.flv$NODE_MEDIA_SIGNED";
  curl --request POST \
  --header "Content-Type: application/json" \
  -d "{\"wsURL\": \"$wsURL\"}" \
  "http://$SERVER_IP_ADDRESS:3333/video-url"
}
startFFmpegLocal() {
  ffmpeg -i tcp://127.0.0.1:8181?listen \
  -c:v copy -c:a aac -ar 44100 -ab 40000 \
  -f flv "rtmp://127.0.0.1:4000$NODE_MEDIA_ROUTE$NODE_MEDIA_SIGNED" &
  sleep 2

  sendLocalWSLink
}
startFFmpegCloud() {
  ffmpeg -i tcp://127.0.0.1:8181?listen \
  -c:v copy -c:a aac -ar 44100 -ab 40000 \
  -f flv "rtmp://$SERVER_IP_ADDRESS:4000$NODE_MEDIA_ROUTE$NODE_MEDIA_SIGNED" &
  sleep 2

  sendCloudWSLink
}
startFFmpegLocalAndCloud() {
  ffmpeg -i tcp://127.0.0.1:8181?listen \
  -c:v copy -c:a aac -ar 44100 -ab 40000 \
  -f flv "rtmp://127.0.0.1:4000$NODE_MEDIA_ROUTE$NODE_MEDIA_SIGNED" \
  -c:v copy -c:a aac -ar 44100 -ab 40000 \
  -f flv "rtmp://$SERVER_IP_ADDRESS:4000$NODE_MEDIA_ROUTE$NODE_MEDIA_SIGNED" &
  sleep 2

  sendCloudWSLink
  sendLocalWSLink
}
startPiCam() {
  ~/picam/picam --alsadev hw:1,0 --tcpout tcp://127.0.0.1:8181 &
}


killProcesses

if ($local && $cloud); then
  echo "start streaming locally & to the cloud"
  startFFmpegLocalAndCloud
  startPiCam
elif ($local); then
  echo "start streaming locally only"
  startFFmpegLocal
  startPiCam
elif ($cloud); then
  echo "start streaming to cloud only"
  startFFmpegCloud
  startPiCam
else
  echo "No Streaming"
fi
