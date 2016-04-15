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
	if [ "$1"== "1" ];then
	echo "scale=4; -1*$tail_num*$order_num1" | bc 
	fi
	if [ "$1"=="0" ];then
	echo "scale=4; $tail_num*$order_num1" | bc  
	fi

}

#######热交换系统中温度（有符号的整形数）转换为温度值##############
#######输入参数：（符号位，15位2进制的数值，精度值）###############
function heatswap_convert_tempreture()
{
	tempreture_num=$(echo "obase=10;ibase=16;" $2 | bc)
	if [ "$1" == "1" ];then
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
	io_binary=$(echo "obase=2;ibase=16;" $io_bytes | bc)
	io_binary_num=${#io_binary}
	io_add_num=$[ 16 - $io_binary_num ]
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
	echo $io_binary
}


function huarui_tempreture()
{
	input1=$(echo $1 | tr a-z A-Z) 
	io_binary=$(echo "obase=10;ibase=16;" $input1 | bc)
	
	echo "scale=4; $io_binary*0.5-90" | bc -l 
}
function huirui_humidity()
{
	io_bytes="$1"
	io_binary=$(echo "obase=10;ibase=16;"$io_bytes | bc)
	
	echo "scale=4; $io_binary+5" | bc -l 
}

function yingweike_tempreture()
{
	io_bytes="$1"
	io_binary=$(echo "obase=10;ibase=16;"$io_bytes | bc)
	
	echo "scale=4; $io_binary" | bc -l 
}


################################################################################
######################八、热交换设备##############################################
####################################################################

# 海特
	echo "海特："
	heatswap_work_alarm=0 ####设备故障告警（初始值无告警）
	heatswap_temperature=0 ####室内温度
	heatswap_humidity=0 ####室内湿度
	
	basic.exe heatswap.txt 2 100 18 $1
	heatswap_work_alarm_recive=$(cat receiveinfo)
	
	if [ "$heatswap_work_alarm_recive" != "" ];then
		hearswap_alarm=${heatswap_work_alarm_recive:28:44}
		echo $hearswap_alarm | grep 46
		status=$?
		if [ $status == "0" ];then 
		heatswap_work_alarm=1
		fi
		
		basic.exe heatswap.txt 5 100 18 $1
		heatswap_temperature_recive=$(cat receiveinfo)
		
		heatswap_temperature_ascii=${heatswap_temperature_recive:30:8}
		echo "test:"$heatswap_temperature_ascii
		heatswap_temperature_temp_hex=$(echo $heatswap_temperature_ascii | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		echo "test:"$heatswap_temperature_temp_hex
		heatswap_temperature_io_binary=$(hex4_binary16   "$heatswap_temperature_temp_hex")
		echo "test:"$heatswap_temperature_io_binary
		heatswap_temperature_symbol=${heatswap_temperature_io_binary:0:1} 
		echo "test:"$heatswap_temperature_symbol
		heatswap_temperature=$(heatswap_convert_tempreture   "$heatswap_temperature_symbol"   "heatswap_temperature_temp_hex"  "0.01")
		echo "test:"$heatswap_temperature
	fi

	# 华瑞
	echo "华瑞："
	basic.exe heatswap.txt 8 100 8 $1
	heatswap_work_alarm_recive1=$(cat receiveinfo)
	if [ "$heatswap_work_alarm_recive1" != "" ];then 
		
		hearswap_alarm=${heatswap_work_alarm_recive1:8:4}
		if [[ $hearswap_alarm == "0000" ]];then 
			heatswap_work_alarm=1
		fi	
		basic.exe heatswap.txt 11 100 8 $1
		heatswap_temperature_recive1=$(cat receiveinfo)
		heatswap_temperature_hex16=${heatswap_temperature_recive1:8:4}
		heatswap_temperature=$(huarui_tempreture "$heatswap_temperature_hex16")
		
		basic.exe heatswap.txt 14 100 8 $1
		heatswap_humidity_recive=$(cat receiveinfo)
		heatswap_humidity_hex16=${heatswap_humidity_recive:8:4}
		
		heatswap_humidity=$(huirui_humidity "$heatswap_humidity_hex16")	
	
	fi
	
	# 英维克
	echo "英维克："
	basic.exe heatswap.txt 17 100 8 $1
	heatswap_work_alarm_recive2=$(cat receiveinfo)
	if [ "$heatswap_work_alarm_recive2" != "" ]; then
		hearswap_alarm_hex16=${heatswap_work_alarm_recive2:8:4}
		if [[ $hearswap_alarm_hex16 != "0000" ]];then 
			heatswap_work_alarm=1
		fi	
		
		basic.exe heatswap.txt 20 100 8 $1
		heatswap_temperature_recive2=$(cat receiveinfo)
		heatswap_temperature_hex16_1=${heatswap_temperature_recive2:8:4}
		heatswap_temperature=$(yingweike_tempreture  "$heatswap_temperature_hex16_1")
			
	fi	
	
	
	echo "告警："$heatswap_work_alarm
	if [ $heatswap_work_alarm == $(cat heatswap_work_alarm) ];then
		echo 1 > heatswap_work_alarm_update
	else
		echo 0 > heatswap_work_alarm_update
	fi
	echo  "$heatswap_work_alarm"  >  heatswap_work_alarm
	
	echo "温度："$heatswap_temperature
	if [ $heatswap_temperature == $(cat heatswap_temperature) ];then
		echo 1 > heatswap_temperature_update
	else
		echo 0 > heatswap_temperature_update
	fi
	echo  "$heatswap_temperature"  >  heatswap_temperature
	
	echo "室内湿度:"$heatswap_humidity
	if [ $heatswap_humidity == $(cat heatswap_humidity) ];then
		echo 1 > heatswap_humidity_update
	else
		echo 0 > heatswap_humidity_update
	fi
	echo  "$heatswap_humidity"  >  heatswap_humidity
