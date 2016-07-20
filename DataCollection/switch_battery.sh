#!/bin/bash
cd /home/pi/UpdateInfo
##############更新传感器文件中的信息
function convert_hex2()
{
   	decimal=$(echo "obase=10;ibase=16;" $1 | bc)
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

##########################四：开关电源##############################
####################################################################
####################################################################
	
	switch_battery_address=0
	basic.exe switch_battery_company.txt 2 100 18 $1
	switch_battery_address_recive=$(cat receiveinfo)
	company_name=${switch_battery_address_recive:74:4}
	
	if [ "$company_name" == "3435" ];then  #艾默生
		switch_battery_address=1;
	fi
	if [ "$company_name" == "3434" ];then
		switch_battery_address=2;
	fi
	if [ "$company_name" == "3438" ];then
		switch_battery_address=3;
	fi
	if [ "$company_name" == "3541" ];then
		switch_battery_address=7;
	fi
	
	if [ $switch_battery_address -eq 1 ];then
		#调用Emerson_switch_battery.sh
		/home/pi/UpdateInfo/Emerson_switch_battery.sh
	fi
	
	if [ $switch_battery_address -eq 2 ];then
		#调用DongLi_switch_battery.sh
		/home/pi/UpdateInfo/DongLi_switch_battery.sh
	fi
	if [ $switch_battery_address -eq 3 ];then
		#调用HuaWei_switch_battery.sh
		/home/pi/UpdateInfo/HuaWei_switch_battery.sh
	fi
	
	if [ $switch_battery_address -eq 7 ];then
		#调用ZhongXing_switch_battery.sh
		/home/pi/UpdateInfo/ZhongXing_switch_battery.sh
	fi
	
	
	
	
	
	

	

	
