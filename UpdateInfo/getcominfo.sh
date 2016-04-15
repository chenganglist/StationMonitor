#!/bin/bash
#cd /home/pi/UpdateInfo

##############获取非智能设备的信息，包括环境量和蓄电池#####
#0092温度一号 0092温度二号 0092湿度一号 0091湿度二号 0000蓄电池 0000蓄电池 0000蓄电池 0000蓄电池（32） 
#07烟感门磁（34) FC水浸外机红外(36) 
#00灯复位继电器(38) 08烟感门磁有效(40) 03水浸外机红外有效(42)

function abs()
{
	echo "scale=4;sqrt($1^2)" | bc -l | awk '{printf ("%8.4f",$0)}'
}
############16进制转10进制######################
function convert_hex_to_decimal()
{
	echo "obase=10;ibase=16;" $1 | bc 
}

##############计算温度一########################
function calculate_temperature_one()
{
	echo "scale=8; (120/818.2)*($1-204.8)-40" | bc -l  | awk '{printf ("%8.4f",$0)}'
}

##############计算温度二 修改 1023 为1024 去掉offset值########################
####修改部分：由于AD参考电压为5.05V所以转换标准值5V之后，需要乘以1.01#########
####修改时间：2015年10月26日###修改人：肖良平#################################
function calculate_temperature_two()
{
	echo "scale=8; (120.0/1024.0)*1.01*$1-40.0 " | bc -l  | awk '{printf ("%8.4f",$0)}'
}

##############计算湿度一########################
function calculate_humidity_one()
{
	echo "scale=8; (100/818.2)*($1-204.8)" | bc -l  | awk '{printf ("%8.4f",$0)}'
}

##############计算湿度二########################
function calculate_humidity_two()
{
	echo "scale=8; (100/1024)*1.01*$1" | bc -l  | awk '{printf ("%8.4f",$0)}'
}

##############计算蓄电池组一:电流########################
function calculate_battery_one()
{
	echo "scale=8; (72.6/818.2)*($1-204.8)" | bc -l  | awk '{printf ("%8.4f",$0)}'
	#| awk '{printf "%.4f", $0}'
}

##############计算蓄电池组二：电压########################
function calculate_battery_two()
{
	echo "scale=8; (71.0/1024)*$1" | bc -l | awk '{printf ("%8.4f",$0)}'
}

######输入一位16进制字符：从0x00-0xFF，输出对应的2进制字符串：从00000000到11111111#######
function convert_one_byte_to_binary()
{
	io_bytes="$1"
	io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
	io_binary_num=${#io_binary}
	io_add_num=$[ 8 - $io_binary_num ]
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
	echo $io_binary
}

function get_threshold()
{
    sql="select Threshold from TSemaphore where ID='$1' and DeviceID='$2'"
    echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db
}

#########################一：非智能设备系统环境量获取#########################
####################################################################
####################################################################
########获取非智能设备的信息，包括环境量和蓄电池########################
arminfo=$(getcominfo.exe $1)
date >>  getcominfo.log
echo "原始数据"$arminfo >>  getcominfo.log
echo "原始数据"$arminfo
size=$(du -sh getcominfo.log | grep M)
if [ -n "$size" ];then
	cp getcominfo.log getcominfo.log.bak
	rm getcominfo.log
	touch getcominfo.log
fi
 ####21个字节的数据，共42个字符，其中：前16个字节即前32个字符为模拟量，两个字节一组，共8个模拟量；
 ####后5个字节即后10个字节为数字量，共40个数字量
arm=${arminfo:28:42}  
arm=$(echo $arm | tr a-z A-Z)    ###转换数据为16进制大写字符串
echo "数据字段"$arm
####################################################################

if [ ! -f "last_time_update_analog" ];then
	date +%s  >  last_time_update_analog
fi
time=$(date +%Y-%m-%d%t%T)
current_time=$(echo $time | date +%s)
time_interval=$(echo "$current_time-$(cat last_time_update_analog)" | bc)
if [ $time_interval -lt 0 ];then
	date +%s  >  last_time_update_analog
fi
echo  $time_interval
if [ $time_interval -ge 30 ];then 
	date +%s  >  last_time_update_analog
#################################温湿度传感器数据的更新#############
#############温度一号###################
	temperature=${arm:0:4}
	v=$(convert_hex_to_decimal   "$temperature")
	decimal_temperature1=$(calculate_temperature_one  "$v")

	if [[ $decimal_temperature1 == $(cat decimal_temperature1) ]];then
		echo 1  >  decimal_temperature1_update
	else
		echo 0  >  decimal_temperature1_update
	fi

	echo  "$decimal_temperature1"  >  decimal_temperature1

	if [[  $(echo "$decimal_temperature1 < -50"|bc) -eq 1 ]];then
		echo  "0"  >  decimal_temperature1
	fi

	if [[  $(echo "$decimal_temperature1 > 80"|bc) -eq 1 ]];then
		echo  "0"  >  decimal_temperature1
	fi
	echo  "温度一号：""$(cat decimal_temperature1)"


	#############温度二号###################
	temperature=${arm:8:4}
	v=$(convert_hex_to_decimal   "$temperature")
	#echo "$v"
	decimal_temperature2=$(calculate_temperature_two   "$v")
	#echo "$decimal_temperature2"

	if [[ $decimal_temperature2 == $(cat decimal_temperature2) ]];then
		echo 1  >  decimal_temperature2_update
	else
		echo 0  >  decimal_temperature2_update
	fi

	echo  "$decimal_temperature2"  >  decimal_temperature2
	if [  $(echo "$decimal_temperature2 < -50"|bc) -eq 1 ];then
		echo  "0"  >  decimal_temperature2
	fi
	if [  $(echo "$decimal_temperature2 > 80"|bc) -eq 1 ];then
		echo  "0"  >  decimal_temperature2
	fi
	echo  "温度二号：""$(cat decimal_temperature2)"

	temp1_too_high_thres=$(get_threshold 0418004001 42020141800003)

	if [ $(echo "$decimal_temperature1 > $temp1_too_high_thres"|bc) -eq 1 ];then
		echo   "1"   >   temperature1_too_high
	else
		echo   "0"   >   temperature1_too_high
	fi


	temp1_super_high_thres=$(get_threshold 0418005001 42020141800003)
	if [ $(echo "$decimal_temperature1 > $temp1_super_high_thres"|bc) -eq 1 ];then
		echo "1"  >   temperature1_super_high
	else
		echo "0"  >   temperature1_super_high	
	fi

	temp1_too_low_thres=$(get_threshold 0418006001 42020141800003)
	if [ $(echo "$decimal_temperature1 < $temp1_too_low_thres"|bc) -eq 1 ];then
		echo "1"  >   temperature1_too_low
	else
		echo "0"  >   temperature1_too_low
	fi

	temp2_too_high_thres=$(get_threshold 0418004001 42020141800004)

	if [ $(echo "$decimal_temperature2 > $temp2_too_high_thres"|bc) -eq 1 ];then
		echo   "1"   >   temperature2_too_high
	else
		echo   "0"   >   temperature2_too_high
	fi

	temp2_super_high_thres=$(get_threshold 0418005001 42020141800004)
	if [ $(echo "$decimal_temperature2 > $temp2_super_high_thres"|bc) -eq 1 ];then
		echo "1"  >   temperature2_super_high
	else
		echo "0"  >   temperature2_super_high	
	fi

	temp2_too_low_thres=$(get_threshold 0418006001 42020141800004)
	if [ $(echo "$decimal_temperature2 < $temp2_too_low_thres"|bc) -eq 1 ];then
		echo "1"  >   temperature2_too_low
	else
		echo "0"  >   temperature2_too_low
	fi




	##############湿度一号###################
	humidity=${arm:4:4}
	v=$(convert_hex_to_decimal   "$humidity")
	decimal_humidity1=$(calculate_humidity_one   "$v")

	if [[ $decimal_humidity1 == $(cat decimal_humidity1) ]];then
		echo 1  >  decimal_humidity1_update
	else
		echo 0  >  decimal_humidity1_update
	fi

	echo  "$decimal_humidity1"  >  decimal_humidity1  

	if [  $(echo "$decimal_humidity1 < 20"|bc) -eq 1 ];then
		echo  "0"  >  decimal_humidity1
	fi
	if [  $(echo "$decimal_humidity1 > 100"|bc) -eq 1 ];then
		echo  "0"  >  decimal_humidity1
	fi
	echo  "湿度一号："$(cat decimal_humidity1)


	##############湿度二号###################
	humidity=${arm:12:4}
	v=$(convert_hex_to_decimal   "$humidity")
	decimal_humidity2=$(calculate_humidity_two   "$v")

	if [[ $decimal_humidity2 == $(cat decimal_humidity2) ]];then
		echo 1  >  decimal_humidity2_update
	else
		echo 0  >  decimal_humidity2_update
	fi

	echo  "$decimal_humidity2"  >  decimal_humidity2
	if [  $(echo "$decimal_humidity2 < 20"|bc) -eq 1 ];then
		echo  "0"  >  decimal_humidity2
	fi
	if [  $(echo "$decimal_humidity2 > 100"|bc) -eq 1 ];then
		echo  "0"  >  decimal_humidity2
	fi
	echo "湿度二号："$(cat decimal_humidity2)

	hum_threshold1=$(get_threshold 0418007001 42020141800003)
	if [ $(echo "$decimal_humidity1 >  $hum_threshold1"|bc) -eq 1 ];then 
		echo  "1"  >  humidity1_too_high
	else
		echo  "0"  >  humidity1_too_high
	fi
	hum_threshold2=$(get_threshold 0418008001 42020141800003)
	if [ $(echo "$decimal_humidity1 < $hum_threshold2"|bc) -eq 1 ];then
		echo  "1"  >  humidity1_too_high
	else
		echo  "0"  >  humidity1_too_low
	fi
	hum_threshold1=$(get_threshold 0418007001 42020141800004)
	if [ $(echo "$decimal_humidity2 > $hum_threshold1"|bc) -eq 1 ];then
		echo  "1"  >  humidity2_too_high  	
	else
		echo  "0"  >  humidity2_too_high
	fi
	hum_threshold2=$(get_threshold 0418008001 42020141800004)
	if [ $(echo "$decimal_humidity2 < $hum_threshold2"|bc) -eq 1 ];then
		echo  "1"  >  humidity2_too_low  
	else
		echo  "0"  >  humidity2_too_low  
	fi


	######################蓄电池组参数解析#################################
	###################第一组蓄电池组前半组电压###################
	voltage=${arm:16:4}
	v=$(convert_hex_to_decimal   "$voltage")
	#echo $v
	forward_half_battery_voltage1=$(calculate_battery_one   "$v")
	#echo $forward_half_battery_voltage1
	if [ "$(echo "$forward_half_battery_voltage1 < 0" | bc)" -eq 1 ];then
		forward_half_battery_voltage1=0   
	fi
	forward_half_battery_voltage1=$(abs $forward_half_battery_voltage1)
	echo "第一组蓄电池组前半组电压："$forward_half_battery_voltage1
	##############第一组蓄电池后半组电压###################
	voltage=${arm:20:4}
	v=$(convert_hex_to_decimal   "$voltage")
	backward_half_battery_voltage1=$(calculate_battery_one   "$v")
	if [ "$(echo "$backward_half_battery_voltage1 < 0" | bc)" -eq 1 ];then
		backward_half_battery_voltage1=0   
	fi
	echo "第一组蓄电池组后半组电压："$backward_half_battery_voltage1
	##############第一组蓄电池组总电压###################
	total_battery_group_voltage=$(echo "scale=4;$forward_half_battery_voltage1+$backward_half_battery_voltage1" | bc -l | awk '{printf "%.4f", $0}')
	echo "第一组蓄电池组总电压："$total_battery_group_voltage
	##############第一组蓄电池组电压差绝对值###################

	battery_minus=$(echo "scale=2;$forward_half_battery_voltage1-$backward_half_battery_voltage1" | bc -l | awk '{printf "%.4f", $0}')
	battery_minus_abs1=$(echo "scale=4;sqrt($battery_minus^2)" | bc -l)

	bat_threshold1=$(get_threshold 0407005001 42020140700004)
	if [ "$(echo "${battery_minus_abs1} > $bat_threshold1" | bc)" -eq 1 ];then
		echo 1 >  voltage_unbalance1
	else
		echo 0 >  voltage_unbalance1
	fi

	##############第二组蓄电池组电压###################
	###################################################
	voltage=${arm:24:4}
	v=$(convert_hex_to_decimal   "$voltage")
	forward_half_battery_voltage2=$(calculate_battery_two   "$v")
	if [ "$(echo "$forward_half_battery_voltage2 < 0" | bc)" -eq 1 ];then
		forward_half_battery_voltage2=0   
	fi
	echo "第二组蓄电池组前半组电压："$forward_half_battery_voltage2
	##############第二组蓄电池后半组电压###################
	voltage=${arm:28:4}
	v=$(convert_hex_to_decimal   "$voltage")
	backward_half_battery_voltage2=$(calculate_battery_two   "$v")
	if [ "$(echo "$backward_half_battery_voltage2 < 0" | bc)" -eq 1 ];then
		backward_half_battery_voltage2=0   
	fi
	echo "第二组蓄电池组后半组电压："$backward_half_battery_voltage2
	##############第二组蓄电池组总电压###################
	total_battery_group_voltage2=$(echo "scale=4;$forward_half_battery_voltage2+$backward_half_battery_voltage2" | bc -l | awk '{printf "%.4f", $0}')
	echo "第二组蓄电池组总电压："$total_battery_group_voltage2

	##############第二组蓄电池组电压差绝对值###################
	battery_minus=$(echo "$forward_half_battery_voltage2-$backward_half_battery_voltage2" | bc -l | awk '{printf "%.4f", $0}')
	battery_minus_abs2=$(echo "scale=4;sqrt($battery_minus^2)" | bc -l)

	bat_threshold2=$(get_threshold 0407005001 42020140700005)
	if [ $(echo "${battery_minus_abs2} > $bat_threshold2" | bc) -eq 1 ];then
		echo 1 >  voltage_unbalance2
	else
		echo 0 >  voltage_unbalance2
	fi

	if [ $(cat forward_half_battery_voltage1) == $forward_half_battery_voltage1 ];then
		echo 1 > forward_half_battery_voltage1_update
	else
		echo 0 > forward_half_battery_voltage1_update
	fi
	if [ $backward_half_battery_voltage1 == $(cat backward_half_battery_voltage1) ];then
	   echo 1 > backward_half_battery_voltage1_update
	else
	   echo 0 > backward_half_battery_voltage1_update
	fi
	if [ $total_battery_group_voltage1 == $(cat total_battery_group_voltage1) ];then
	   echo 1 > total_battery_group_voltage1_update
	else
	   echo 0 > total_battery_group_voltage1_update
	fi

	if [ $forward_half_battery_voltage2 == $(cat forward_half_battery_voltage2) ];then
		echo 1 > forward_half_battery_voltage2_update
	else
		echo 0 > forward_half_battery_voltage2_update
	fi
	if [ $backward_half_battery_voltage2 == $(cat backward_half_battery_voltage2) ];then
		echo 1 > backward_half_battery_voltage2_update
	else
		echo 0 > backward_half_battery_voltage2_update
	fi
	if [ $total_battery_group_voltage2 == $(cat total_battery_group_voltage2) ];then
		echo 1 > total_battery_group_voltage2_update
	else
		echo 0 > total_battery_group_voltage2_update
	fi
	echo $forward_half_battery_voltage1 > forward_half_battery_voltage1
	echo $backward_half_battery_voltage1 > backward_half_battery_voltage1
	echo $total_battery_group_voltage1 > total_battery_group_voltage1
	echo $forward_half_battery_voltage2 > forward_half_battery_voltage2
	echo $backward_half_battery_voltage2 > backward_half_battery_voltage2
	echo $total_battery_group_voltage2 > total_battery_group_voltage2
fi

####################解析IO量第一个IO字节##################
#####################数据的有效性判断#####################
#######################第四个IO字节#######################
io_bytes=${arm:38:2}
io_binary=$(convert_one_byte_to_binary   "$io_bytes")
io_smoke1_valid=${io_binary:0:1}
io_smoke2_valid=${io_binary:1:1}
io_smoke3_valid=${io_binary:2:1}
io_smoke4_valid=${io_binary:3:1}
###################门磁##############################
door_magnetic1_valid=${io_binary:4:1}
door_magnetic2_valid=${io_binary:5:1}
door_magnetic3_valid=${io_binary:6:1}
door_magnetic4_valid=${io_binary:7:1}
echo "烟感一号有效位："$io_smoke1_valid
echo "烟感二号有效位："$io_smoke2_valid
echo "烟感三号有效位："$io_smoke3_valid
echo "烟感四号有效位："$io_smoke4_valid
echo "门磁一号有效位："$door_magnetic1_valid
echo "门磁二号有效位："$door_magnetic2_valid
echo "门磁三号有效位："$door_magnetic3_valid
echo "门磁四号有效位："$door_magnetic4_valid

#######################第五个IO字节#######################
io_bytes=${arm:40:2}
io_binary=$(convert_one_byte_to_binary   "$io_bytes")
##########################################################
##########################水浸############################
soak_resist1_valid=${io_binary:0:1}
soak_resist2_valid=${io_binary:1:1}
soak_resist3_valid=${io_binary:2:1}
soak_resist4_valid=${io_binary:3:1}
#######################外机防盗#####################
burglar_resist1_valid=${io_binary:4:1}
burglar_resist2_valid=${io_binary:5:1}
#########################红外######################
infared1_valid=${io_binary:6:1}
infared2_valid=${io_binary:7:1}

echo "水浸一号有效位："$soak_resist1_valid
echo "水浸二号有效位："$soak_resist2_valid
echo "水浸三号有效位："$soak_resist3_valid
echo "水浸四号有效位："$soak_resist4_valid
echo "外机一号有效位："$burglar_resist1_valid
echo "外机二号有效位："$burglar_resist2_valid
echo "红外一号有效位："$infared1_valid
echo "红外二号有效位："$infared2_valid


######################解析IO量第一个IO字节#####################
io_bytes=${arm:32:2}
io_binary=$(convert_one_byte_to_binary   "$io_bytes")
#######################第一个IO字节#################################
##############################更新烟感在数据库中的信息##############
io_smoke1=${io_binary:0:1}
io_smoke2=${io_binary:1:1}
io_smoke3=${io_binary:2:1}
io_smoke4=${io_binary:3:1}

if [ $io_smoke1_valid -gt 0 ];then
	echo  "$io_smoke1"  >  io_smoke1
else
	echo  "0"  >  io_smoke1
fi
if [ $io_smoke2_valid -gt 0 ];then
	echo  "$io_smoke2"  >  io_smoke2
else
	echo  "0"  >  io_smoke2
fi
if [ $io_smoke3_valid -gt 0 ];then
	echo  "$io_smoke3"  >  io_smoke3
else
	echo  "0"  >  io_smoke3
fi
if [ $io_smoke4_valid -gt 0 ];then
	echo  "$io_smoke4"  >  io_smoke4
else
	echo  "0"  >  io_smoke4
fi

if [ $io_smoke1 = $(cat io_smoke1) ];then
    echo 1 >  io_smoke1_update
else
    echo 0 >  io_smoke1_update
fi

if [ $io_smoke2 = $(cat io_smoke2) ];then
    echo 1 >  io_smoke2_update
else
    echo 0 >  io_smoke2_update
fi

if [ $io_smoke3 = $(cat io_smoke3) ];then
    echo 1 >  io_smoke3_update
else
    echo 0 >  io_smoke3_update
fi

if [ $io_smoke4 = $(cat io_smoke4) ];then
    echo 1 >  io_smoke4_update
else
    echo 0 >  io_smoke4_update
fi

echo "烟感""$(cat io_smoke1)""$(cat io_smoke2)""$(cat io_smoke3)""$(cat io_smoke4)"
###################门磁##############################
door_magnetic1=${io_binary:4:1}
door_magnetic2=${io_binary:5:1}
door_magnetic3=${io_binary:6:1}
door_magnetic4=${io_binary:7:1}

if [ $door_magnetic1_valid -gt 0 ];then
	echo  "$door_magnetic1"  >  door_magnetic1
else
	echo  "0"  >  door_magnetic1
fi
if [ $door_magnetic2_valid -gt 0 ];then
	echo  "$door_magnetic2"  >  door_magnetic2
else
	echo  "0"  >  door_magnetic2
fi
if [ $door_magnetic3_valid -gt 0 ];then
	echo  "$door_magnetic3"  >  door_magnetic3
else
	echo  "0"  >  door_magnetic3
fi
if [ $door_magnetic4_valid -gt 0 ];then
	echo  "$door_magnetic4"  >  door_magnetic4
else
	echo  "0"  >  door_magnetic4
fi

if [ $door_magnetic1 = $(cat door_magnetic1) ];then
    echo 1 >  door_magnetic1_update
else
    echo 0 >  door_magnetic1_update
fi

if [ $door_magnetic2 = $(cat door_magnetic2) ];then
    echo 1 >  door_magnetic2_update
else
    echo 0 >  door_magnetic2_update
fi

if [ $door_magnetic3 = $(cat door_magnetic3) ];then
    echo 1 >  door_magnetic3_update
else
    echo 0 >  door_magnetic3_update
fi

if [ $door_magnetic4 = $(cat door_magnetic4) ];then
    echo 1 >  door_magnetic4_update
else
    echo 0 >  door_magnetic4_update
fi

echo "门磁""$(cat door_magnetic1)""$(cat door_magnetic2)""$(cat door_magnetic3)""$(cat door_magnetic4)"

#######################第二个IO字节#######################
io_bytes=${arm:34:2}
io_binary=$(convert_one_byte_to_binary   "$io_bytes")
##########################################################
##########################水浸############################
soak_resist1=${io_binary:0:1}
soak_resist2=${io_binary:1:1}
soak_resist3=${io_binary:2:1}
soak_resist4=${io_binary:3:1}

if [ $soak_resist1_valid -gt 0 ];then
	echo  "$soak_resist1"  >  soak_resist1
else
	echo  "0"  >  soak_resist1
fi
if [ $soak_resist2_valid -gt 0 ];then
	echo  "$soak_resist2"  >  soak_resist2
else
	echo  "0"  >  soak_resist2
fi
if [ $soak_resist3_valid -gt 0 ];then
	echo  "$soak_resist3"  >  soak_resist3
else
	echo  "0"  >  soak_resist3
fi
if [ $soak_resist4_valid -gt 0 ];then
	echo  "$soak_resist4"  >  soak_resist4
else
	echo  "0"  >  soak_resist4
fi

if [ $soak_resist1 = $(cat soak_resist1) ];then
    echo 1 >  soak_resist1_update
else
    echo 0 >  soak_resist1_update
fi

if [ $soak_resist2 = $(cat soak_resist2) ];then
    echo 1 >  soak_resist2_update
else
    echo 0 >  soak_resist2_update
fi

if [ $soak_resist3 = $(cat soak_resist3) ];then
    echo 1 >  soak_resist3_update
else
    echo 0 >  soak_resist3_update
fi

if [ $soak_resist4 = $(cat soak_resist4) ];then
    echo 1 >  soak_resist4_update
else
    echo 0 >  soak_resist4_update
fi

echo "水浸""$(cat soak_resist1)""$(cat soak_resist2)""$(cat soak_resist3)""$(cat soak_resist4)"
#######################外机防盗#####################
burglar_resist1=${io_binary:4:1}
burglar_resist2=${io_binary:5:1}
if [ $burglar_resist1_valid -gt 0 ];then
	echo  "$burglar_resist1"  >  burglar_resist1
else
	echo  "0"  >  burglar_resist1
fi
if [ $burglar_resist2_valid -gt 0 ];then
	echo  "$burglar_resist2"  >  burglar_resist2
else
	echo  "0"  >  burglar_resist2
fi
if [ $burglar_resist1 = $(cat burglar_resist1) ];then
    echo 1 >  burglar_resist1_update
else
    echo 0 >  burglar_resist1_update
fi

if [ $burglar_resist2 = $(cat burglar_resist2) ];then
    echo 1 >  burglar_resist2_update
else
    echo 0 >  burglar_resist2_update
fi
echo "外机防盗""$(cat burglar_resist1)""$(cat burglar_resist2)"
#########################红外######################
infared1=${io_binary:6:1}
infared2=${io_binary:7:1}
if [ $infared1_valid -gt 0 ];then
	echo  "$infared1"  >  infared1
else
	echo  "0"  >  infared1
fi

if [ $infared2_valid -gt 0 ];then
	echo  "$infared2"  >  infared2
else
	echo  "0"  >  infared2
fi

if [ $infared1 = $(cat infared1) ];then
    echo 1 >  infared1_update
else
    echo 0 >  infared1_update
fi

if [ $infared2 = $(cat infared2) ];then
    echo 1 >  infared2_update
else
    echo 0 >  infared2_update
fi

echo "红外""$(cat infared1)""$(cat infared2)"

#########################################################################



#######################第三个IO字节#######################
io_bytes=${arm:36:2}
io_binary=$(convert_one_byte_to_binary   "$io_bytes")
##########################################################
##########################灯状态##############################
light_status=${io_binary:0:1}
echo  "$light_status"  >  light_status
##########################复位状态###########################