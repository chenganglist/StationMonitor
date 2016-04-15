ipaddr=$(ifconfig ppp1 | grep 'inet'| awk '{print $2}' | sed -e "s/addr\://")
echo $ipaddr
