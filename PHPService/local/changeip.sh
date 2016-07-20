interface="ppp0"
dstFile="/home/pi/www/services/FSUService.wsdl"

ip=`ifconfig ${interface} 2>/dev/null | awk -F ":"  '/inet addr/{split($2,a," ");print a[1]}'`

if [ -z "$ip" ]; then
	echo "No IP: ${ip}"
	exit 0
else
	echo "Find IP:${ip}"
	echo "Change IP in "
	sed -i "s?http://\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}:8080?http://${ip}:8080?g" ${dstFile}
	cat ${dstFile}
	grep --color -ine ${ip} ${dstFile}
fi
