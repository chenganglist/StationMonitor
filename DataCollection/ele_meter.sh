#!/bin/bash
cd /home/pi/UpdateInfo
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
	
	if [ "$1" -eq 1 ];then
		echo "scale=4; -1*$tail_num*(2^($order_num-127)) -l" | bc 
	fi
	if [ "$1" -eq 0 ];then
		echo "scale=4; $tail_num*(2^($order_num-127)) -l" | bc  
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

##########################四：智能电表##############################
####################################################################
####################################################################

	ele_meter_address=0
	ele_meter_company.exe 1 $1
	ele_meter_address=$(echo $?)
	
	
	if [ $ele_meter_address -eq 0 ];then
		ele_meter_company.exe 2 $1 
		ele_meter_address=$(echo $?)
	fi
	if [ $ele_meter_address -eq 0 ];then
		ele_meter_company.exe 3 $1
		ele_meter_address=$(echo $?)
	fi
	if [ $ele_meter_address -eq 0 ];then
		ele_meter_company.exe 4 $1
		ele_meter_address=$(echo $?)
		echo "address:"$ele_meter_address
	fi
	
	echo "address:"$ele_meter_address
	ele_meter_Ua_Ub_Uc="00000000000000000000"
	
	if [ $ele_meter_address -eq 1 ];then 
	
		echo "安瑞科:"
		basic.exe ele_meter_Uabc.txt 1 100 8 $1
		ele_meter_Ua_Ub_Uc=$(cat receiveinfo)
		
	fi
	if [ $ele_meter_address -eq 2 ];then 
		basic.exe ele_meter_Uabc.txt 2 100 8 $1
		ele_meter_Ua_Ub_Uc=$(cat receiveinfo)
	fi
	if [ $ele_meter_address -eq 4 ];then 
		basic.exe ele_meter_Uabc.txt 4 100 8 $1
		ele_meter_Ua_Ub_Uc=$(cat receiveinfo)
	fi
	
	decimal_A_phase_voltage=0
	decimal_B_phase_voltage=0
	decimal_C_phase_voltage=0
	
	
	
    if [ $ele_meter_address -ne 3 ];then
	
	#############################A相电压的解析与更新####################	
		A_phase_voltage=${ele_meter_Ua_Ub_Uc:6:4}
		decimal_A_phase_voltage=$(convert_hex2   "$A_phase_voltage"   "0.1")

	#############################B相电压的解析与更新####################
		B_phase_voltage=${ele_meter_Ua_Ub_Uc:10:4}
		decimal_B_phase_voltage=$(convert_hex2   "$B_phase_voltage"   "0.1")
		
	##############################C相电压的解析与更新#####################
		C_phase_voltage=${ele_meter_Ua_Ub_Uc:14:4}
		decimal_C_phase_voltage=$(convert_hex2   "$C_phase_voltage"   "0.1")
	fi
	
	if [ $ele_meter_address -eq 3 ];then 
	
		basic.exe ele_meter_Uabc.txt 3 100 18 $1
		ele_meter_Ua_Ub_Uc=$(cat receiveinfo)
		temp_ascii_a=${ele_meter_Ua_Ub_Uc:34:16}
		temp_hex_a=$(echo $temp_ascii_a | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		io_binary_a=$(hex8_binary16   "$temp_hex_a")
		symbol_a=${io_binary_a:0:1}
		order_code_a=${io_binary_a:1:8}
		tail_code_a=${io_binary_a:8:23}
		
		decimal_A_phase_voltage=$(convert_Uabc_32   "$symbol_a"   "order_code_a"  "tail_code_a")
	
#############################B相电压的解析与更新####################

		temp_ascii_b=${ele_meter_Ua_Ub_Uc:50:16}
		temp_hex_b=$(echo $temp_ascii_b | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		io_binary_b=$(hex8_binary16   "$temp_hex_b")
		symbol_b=${io_binary_b:0:1}
		order_code_b=${io_binary_b:1:8}
		tail_code_b=${io_binary_b:8:23}
		
		decimal_B_phase_voltage=$(convert_Uabc_32   "$symbol_b"   "order_code_b"  "tail_code_b")
	
##############################C相电压的解析与更新#####################

		temp_ascii_c=${ele_meter_Ua_Ub_Uc:66:16}
		temp_hex_c=$(echo $temp_ascii_c | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
		io_binary_c=$(hex8_binary16   "$temp_hex_c")
		symbol_c=${io_binary_c:0:1}
		order_code_c=${io_binary_c:1:8}
		tail_code_c=${io_binary_c:8:23}
		
		decimal_C_phase_voltage=$(convert_Uabc_32   "$symbol_c"   "order_code_c"  "tail_code_c")
	fi
	
	
	
	if [ $(echo "$decimal_A_phase_voltage < 30"|bc)  -eq 1 ];then 
        if [ $(echo "$decimal_B_phase_voltage < 30"|bc) -eq  1 ];then
			if [ $(echo "$decimal_C_phase_voltage < 30"|bc) -eq 1 ] ;then
			   echo   "1"   >   no_electricity
			else
			   echo   "0"   >   no_electricity
			fi
		else
			echo   "0"   >   no_electricity
		fi
	else
		echo   "0"   >   no_electricity
	fi
	
	echo "A0:"$decimal_A_phase_voltage
	echo "B0:"$decimal_B_phase_voltage
	echo "C0:"$decimal_C_phase_voltage
	if [ $decimal_A_phase_voltage == $(cat decimal_A_phase_voltage) ];then
		echo 1 > decimal_A_phase_voltage_update
	else
		echo 0 > decimal_A_phase_voltage_update
	fi
	if [ $decimal_B_phase_voltage == $(cat decimal_B_phase_voltage) ];then
		echo 1 > decimal_B_phase_voltage_update
	else
		echo 0 > decimal_B_phase_voltage_update
	fi
	if [ $decimal_C_phase_voltage == $(cat decimal_C_phase_voltage) ];then
		echo 1 > decimal_C_phase_voltage_update
	else
		echo 0 > decimal_C_phase_voltage_update
	fi
	echo  "$decimal_A_phase_voltage"  >  decimal_A_phase_voltage
	echo  "$decimal_B_phase_voltage"  >  decimal_B_phase_voltage
	echo  "$decimal_C_phase_voltage"  >  decimal_C_phase_voltage