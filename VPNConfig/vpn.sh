#!/bin/bash
# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
#service ipsec restart
#sleep 5
#ipsec auto --up Wan
service xl2tpd restart
sleep 5
echo "c Wan" > /run/xl2tpd/l2tp-control
sleep 20
ifconfig

