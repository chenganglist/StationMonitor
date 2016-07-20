#!/bin/bash
cd /home/pi/UpdateInfo

function convert_hex2()
{
   	decimal=$(echo "obase=10;ibase=16;" $1 | bc)
	echo "scale=4; $decimal*$2" | c -l 
}

############################$1为16进制4位输入，输出为16位2进制，输出共16位#####################################
function hex4_binary16()
{
	io_bytes="$1"
	io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
	io_binary_num=${#io_binary}
	io_add_num=$[ 16 - $io_binary_num ]
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
	echo $io_binary
}


function convert_Uabc_32()
{
   	order_num=$(echo "obase=10;ibase=2;" $2 | bc)
	tail_num=$(echo "obase=10;ibase=2;" $3 | bc)
	order_num1=$((2**(order_num-127)))
	if ["$1" -eq 1];then
	echo "scale=4; -1*$tail_num*$order_num1" | bc 
	fi
	if ["$1" -eq 0];then
	echo "scale=4; $tail_num*$order_num1" | bc  
	fi

}

#######热交换系统中温度（有符号的整形数）转换为温度值##############
#######输入参数：（符号位，15位2进制的数值，精度值）###############
function heatswap_convert_tempreture()
{
	tempreture_num=$(echo "obase=10;ibase=2;" $2 | bc)
	if [ "$1" -eq 1 ];then
		echo "scale=4; -1*$tempreture_num*$3" | bc 
	else
		echo "scale=4; $tempreture_num*$3" | bc 
	fi
	
}



############################$1为16进制n位输入，输出为4n位2进制，$2为4n #####################################
function hex4_binary16()
{
	io_bytes="$1"
	io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
	io_binary_num=${#io_binary}
	
	io_add_num=$[ $2 - $io_binary_num ]
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
	echo $io_binary
}




##########################五：门禁状态############################
####################################################################
####################################################################
	echo "高新兴门禁："
	guard_system_door_status=0    ###门禁系统门磁开关状态
	basic.exe door.txt 2 100 22 $1
	guard_system_door_status_recive1=$(cat receiveinfo)
	if [ "$guard_system_door_status_recive1" != "" ];then
		status1=${guard_system_door_status_recive1:98:4}
		
		if [ "$status1" == "3031" ];then 
			guard_system_door_status=1   ##门磁有告警，开关状态为开
		fi
	fi

	echo "传通电子门禁："
	basic.exe door.txt 17 100 21 $1
	guard_system_door_status_recive2=$(cat receiveinfo)
	if [ "$guard_system_door_status_recive2" != "" ];then
		status2=${guard_system_door_status_recive2:6:2}
		binary_status2=$(hex4_binary16   "$status2" "8")
		flag=${binary_status2:7:1}
		if [ "$flag" == "1" ];then 
			guard_system_door_status=1   ##开关状态为开
		fi
	fi
	
	####中兴门禁；获取权限
	echo "中兴门禁："
	basic.exe door.txt 8 100 32 $1
	basic.exe door.txt 11 100 20 $1
	guard_system_door_status_recive3=$(cat receiveinfo)
	if [ "$guard_system_door_status_recive3" != "" ];then
		ascii_status=${guard_system_door_status_recive3:26:8}
		temp_hex_status1=$(echo $ascii_status | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		io_binary_status1=$(hex4_binary16   "$temp_hex_status1"  "16")
		status_jiankong=${io_binary_status1:5:1}
		status_open_close=${io_binary_status1:12:1}
		
		if [ "$status_jiankong" == "1" ];then 
			if [ "$status_open_close" == "1" ];then
				guard_system_door_status=1   ##门磁有告警，开关状态为开
			fi
		fi
	fi
	
	echo "门磁状态："$guard_system_door_status
	if [ $guard_system_door_status == $(cat guard_system_door_status) ];then
		echo 1 > guard_system_door_status_update
	else
		echo 0 > guard_system_door_status_update
	fi
	echo  "$guard_system_door_status "  >  guard_system_door_status 
	