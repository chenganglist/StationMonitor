#!/bin/sh
#service ipsec restart
#sleep 5
#ipsec auto --up Wan
service xl2tpd restart 
sleep 1
echo "c Wan" > /run/xl2tpd/l2tp-control  
sleep 1
ifconfig
sql="select SCIP from FSUINFO"
SCIP=$(echo  "$sql;"  |  sqlite3  /home/pi/www/services/FSUINFO.db)
route add -host $SCIP dev ppp0               
