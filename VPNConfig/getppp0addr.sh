ipaddr=$(ifconfig ppp0 | grep 'inet'| awk '{print $2}' | sed -e "s/addr\://")
echo $ipaddr
