service xl2tpd restart
echo "c Wan" > /run/xl2tpd/l2tp-control

result=$(ping -c  2 -q  10.10.1.1 | grep "0 received")
while [[ 1 ]];do
	if [ -n "$result" ];then 
		service xl2tpd restart
		echo "c Wan" > /run/xl2tpd/l2tp-control
	fi
	sleep 30
done
