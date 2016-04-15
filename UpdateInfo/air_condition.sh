#!/bin/bash
cd /home/pi/UpdateInfo
##############更新传感器文件中的信息
function convert_hex2()
{
	input1=$(echo $1 | tr a-z A-Z) 
   	decimal=$(echo "obase=10;ibase=16;" $input1 | bc)
	echo "scale=4; $decimal*$2" | bc -l 
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

############################$1为16进制8位输入，输出为16位2进制，输出共16位#####################################
function hex8_binary16()
{
	io_bytes="$1"
	io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
	io_binary_num=${#io_binary}
	io_add_num=$[ 32 - $io_binary_num ]
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
	echo $io_binary
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

##########################三：普通空调#################################
####################################################################
####################################################################

air_condition_abnormal_alarm=0    ###0表示正常工作异常告警
air_condition_temperature=0    	  ###空调回风温度

###TCL
	echo "TCL："
	basic.exe air.txt 2 200 11 $1
	air_condition_status1=$(cat receiveinfo)
	if [ "$air_condition_status1" != "" ];then
		alarm1=${air_condition_status1:28:4}
		if [ "$alarm1" != "0000" ];then
			air_condition_abnormal_alarm=1
		fi
		basic.exe air.txt 8 100 11 $1
		air_condition_temperature1=$(cat receiveinfo)
		
		temperature1=${air_condition_temperature1:20:2}
		air_condition_temperature=$(convert_hex2   "$temperature1"   "1") 
		
	fi
	
###格力
	echo "格力空调："
	basic.exe air.txt 3 200 18 $1
	air_condition_status2=$(cat receiveinfo)
	if [ "$air_condition_status2" != "" ];then
		alarm2="${air_condition_status2:110:4}" 
		if [ "$alarm2" != "3030" ] ; then 
			air_condition_abnormal_alarm=1
		fi
		
		basic.exe air.txt 9 100 18 $1
		air_condition_temperature2=$(cat receiveinfo)
		ascii_temperature2=${air_condition_temperature2:86:8}
		hex_temperature2=$(echo $ascii_temperature2 | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		air_condition_temperature=$(convert_hex2   "$hex_temperature2"   "1")
	fi
	
##科龙	
	echo "科龙："
	basic.exe air.txt 4 200 18 $1
	air_condition_status3=$(cat receiveinfo)
	if [ "$air_condition_status3" != "" ];then
		
		alarm3=${air_condition_status2:26:44}
		if [ "$alarm3" != "30303030303030303030303030303030303030303030" ];then
			air_condition_abnormal_alarm=1
		fi
		
		basic.exe air.txt 10 100 18 $1
		air_condition_temperature3=$(cat receiveinfo)
		ascii_temperature3=${air_condition_temperature3:82:8}
		hex_temperature3=$(echo $ascii_temperature3 | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		air_condition_temperature=$(convert_hex2   "$hex_temperature3"   "0.01") 
	fi


###美的	
	echo "美的："
	basic.exe air.txt 5 200 14 $1
	air_condition_status4=$(cat receiveinfo)
	if [ "$air_condition_status4" != "" ];then
		alarm4=${air_condition_status4:18:6}
		if [ "$alarm4" != "000000" ];then
			air_condition_abnormal_alarm=1
		fi
		basic.exe air.txt 11 100 14 $1
		air_condition_temperature4=$(cat receiveinfo)
		temperature4=${air_condition_temperature4:16:2}
	
		air_condition_temperature=$(convert_hex2   "$temperature4"   "1") 
		
	fi
	
	echo "空调告警状态(0正常，1告警):"$air_condition_abnormal_alarm
	if [ $air_condition_abnormal_alarm == $(cat air_condition_abnormal_alarm) ];then
		echo 1 > air_condition_abnormal_alarm_update
	else
		echo 0 > air_condition_abnormal_alarm_update
	fi
	echo  "$air_condition_abnormal_alarm "  >  air_condition_abnormal_alarm 
	

	echo "空调温度"$air_condition_temperature
	if [ $air_condition_temperature == $(cat air_condition_temperature) ];then
		echo 1 > air_condition_temperature_update
	else
		echo 0 > air_condition_temperature_update
	fi
	echo  "$air_condition_temperature "  >  air_condition_temperature 
	
	
	battery_abnormal_alarm=0    ###运行温度设定值
	if [ $battery_abnormal_alarm == $(cat battery_abnormal_alarm) ];then
		echo 1 > battery_abnormal_alarm_update
	else
		echo 0 > battery_abnormal_alarm_update
	fi
	echo  "$battery_abnormal_alarm "  >  battery_abnormal_alarm
	
	air_condition_open=0    ###1表示开机远程开机
	if [ $air_condition_open == $(cat air_condition_open) ];then
		echo 1 > air_condition_open_update
	else
		echo 0 > air_condition_open_update
	fi
	echo  "$air_condition_open "  >  air_condition_open
	
	air_condition_close=0    ###1表示开机远程开机
	if [ $air_condition_close == $(cat air_condition_close) ];then
		echo 1 > air_condition_close_update
	else
		echo 0 > air_condition_close_update
	fi
	echo  "$air_condition_close "  >  air_condition_close
	
	