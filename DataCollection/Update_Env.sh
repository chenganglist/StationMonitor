#!/bin/bash
cd /home/pi/UpdateInfo

while [[ 1 ]];do  ###循环定时更新读取数据
	if [ ! -f "last_time_update_env1" ];then
		date +%s  >  last_time_update_env1
	fi
	time=$(date +%Y-%m-%d%t%T)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_update_env1)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_update_env1
	fi
	echo  $time_interval
	if [ $time_interval -ge 2 ];then 
	    date +%s  >  last_time_update_env1
	else
		sleep 1
		continue
	fi
	
	###更新蓄电池和环境量的信息
	/home/pi/UpdateInfo/getcominfo.sh $1

	echo "One Circle info Updated"

done
