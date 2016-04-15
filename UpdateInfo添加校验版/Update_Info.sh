#!/bin/bash
cd /home/pi/UpdateInfo

while [[ 1 ]];do  ###循环定时更新读取数据
	if [ ! -f "last_time_update1" ];then
		date +%s  >  last_time_update1
	fi
	time=$(date +%Y-%m-%d%t%T)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_update1)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_update1
	fi
	echo  $time_interval
	if [ $time_interval -ge 30 ];then 
	    date +%s  >  last_time_update1
	else
		sleep 1
		continue
	fi
	
	###更新蓄电池和环境量的信息
	#/home/pi/UpdateInfo/getcominfo.sh $1

	###更新空调的信息
	/home/pi/UpdateInfo/air_condition.sh $1

	###更新门禁的信息
	/home/pi/UpdateInfo/door.sh $1

	###更新智能电表的信息
	/home/pi/UpdateInfo/ele_meter.sh $1

	###更新热交换的信息
	/home/pi/UpdateInfo/heatswap.sh $1

	###更新DongLi开关电源的信息
	/home/pi/UpdateInfo/switch_battery.sh $1


	echo "One Circle info Updated"

done
