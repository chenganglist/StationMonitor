#!/bin/bash
while [[ 1 ]];do
    result=$(ifconfig | grep "10.10.1.1")
    if [ -z "$result" ];then
       /home/pi/UpdateInfo/vpnstart.sh
       sleep 10
       route add -net 10.10.1.0/24 gw 10.10.1.1
    else
       echo "vpn connection is ok"
    fi
    sleep 2
done
