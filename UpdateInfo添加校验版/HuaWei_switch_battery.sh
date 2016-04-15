#!/bin/bash
cd /home/pi/UpdateInfo
##############更新传感器文件中的信息
###########################一：华为开关电源信息更新#####################
####################################################################
####################################################################
function convert_Uabc_32()
{
	
   	order_num=$(echo "obase=10;ibase=2;" $2 | bc)
	
	
	tail_num=$(echo "obase=10;ibase=2;" $3 | bc)

	order_num1=$(echo "2^($order_num-127)" | bc -l)

	if [ "$1" -eq 1 ];then
	echo "scale=4; -1*(1+$tail_num/8388608)*$order_num1" | bc 
	fi
	if [ "$1" -eq 0 ];then
	echo "scale=4; (1+$tail_num/8388608)*$order_num1" | bc  
	fi

}

function DataF_convert_Uabc()
{
   	temp_hex_a=$(echo $1 | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e)
	
	io_binary_a=$(hex8_binary16   "$temp_hex_a")
	
	symbol_a=${io_binary_a:0:1}
	
	order_code_a=${io_binary_a:1:8}
	
	tail_code_a=${io_binary_a:9:23}
	
	switch_power_voltage_A=$(convert_Uabc_32   "$symbol_a"   "$order_code_a"  "$tail_code_a")
	echo "$switch_power_voltage_A"
}  

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

	



######################################直流告警#######################################

    battery_melt_alarm=0    ###0表示正常电池熔丝故障告警
	basic.exe huawei.txt 2 100 20  $1
	recive_dc_alarm=$(cat receiveinfo)
	
	
	
	battery_melt_alarm1=${recive_dc_alarm:94:4} ##电池1熔丝故障
	if [ "$battery_melt_alarm1" == "3833" ];then
		battery_melt_alarm=1
	fi
#	if [ "$battery_melt_alarm" -ne 1 ];then
		battery_melt_alarm2=${recive_dc_alarm:98:4} ##电池2熔丝故障
		if [ "$battery_melt_alarm2" == "3834" ];then
		battery_melt_alarm=1
		fi
#	fi
	if [ "$battery_melt_alarm" -ne 1 ];then
		battery_melt_alarm3=${recive_dc_alarm:102:4} ##电池3熔丝故障
		if [ "$battery_melt_alarm3" == "3835" ];then
			battery_melt_alarm=1
		fi
	fi	
	if [ "$battery_melt_alarm" -ne 1 ];then
		battery_melt_alarm4=${recive_dc_alarm:106:4} ##电池4熔丝故障
		if [ "$battery_melt_alarm4" == "3836" ];then
			battery_melt_alarm=1
		fi
	fi	
	if [ "$battery_melt_alarm" -ne 1 ];then
		battery_melt_alarm5=${recive_dc_alarm:110:4} ##电池5熔丝故障
		if [ "$battery_melt_alarm5" == "3837" ];then
			battery_melt_alarm=1
		fi
	fi	
	if [ "$battery_melt_alarm" -ne 1 ];then
		battery_melt_alarm6=${recive_dc_alarm:114:4} ##电池6熔丝故障
		if [ "$battery_melt_alarm6" == "3838" ];then
			battery_melt_alarm=1
		fi
	fi	
	
	echo "电池熔丝故障："$battery_melt_alarm
	echo  "$battery_melt_alarm"  >  battery_melt_alarm
	
	
	charge_current_over=0    ###0表示正常电池充电过流告警
	
	charge_current_over1=${recive_dc_alarm:118:4} ##电池1组充电过流故障
	echo "charge_current_over1:"$charge_current_over1
	
	
	if [ "$charge_current_over1" == "3839" ];then
		
		charge_current_over=1;
	fi
	if [ "$charge_current_over" -ne 1 ];then
		charge_current_over2=${alarm_recive:122:4} ##电池2组充电过流故障
		if [ "$charge_current_over2" == "3841" ];then
			echo "test3:"$charge_current_over
			battery_melt_alarm=1
		fi
	fi	
	
	echo "电池充电过流告警："$charge_current_over
	echo  "$charge_current_over"  >  charge_current_over
	
	
	charge_temperature_over=0    ###0表示正常电池温度过高告警>32
	charge_temperature_over1=${recive_dc_alarm:126:4} ##电池组1温度过高故障
	if [ "$charge_temperature_over1" == "3842" ];then
		charge_temperature_over=1;
	fi
	if [ "$charge_temperature_over" -ne 1 ];then
		charge_temperature_over2=${recive_dc_alarm:130:4} ##电池2组温度过高故障
		if [ "$charge_temperature_over2" == "3843" ];then
			charge_temperature_over=1
		fi
	fi
	
	echo "正常电池温度过高告警："$charge_temperature_over
	echo  "$charge_temperature_over"  >  charge_temperature_over
	
	
	
	supply_alarm=0    ###0表示正常系统处于蓄电池供电状态
	supply_alarm1=${recive_dc_alarm:266:4} ##蓄电池供电状态故障
	if [ "$supply_alarm1" == "4145" ];then
		supply_alarm=1;
	fi
	
	echo "蓄电池供电状态故障："$supply_alarm
	echo  "$supply_alarm"  >  supply_alarm
	
	
	dc_voltage_output_lower=0    ###0表示正常直流输出电压过低告警<47
	dc_voltage_output_diff=${recive_dc_alarm:442:4} ##输出电压过低告警
	if [ "$dc_voltage_output_diff" == "3844" ];then
		dc_voltage_output_lower=1;
	fi
	
	echo "正常直流输出电压过低告警："$dc_voltage_output_lower
	echo  "$dc_voltage_output_lower"  >  dc_voltage_output_lower
	
	dc_voltage_output_higher=0    ###0表示正常直流输出电压过高告警>57.5
	
	if [ "$dc_voltage_output_diff" == "3843" ];then
		dc_voltage_output_higher=1;
	fi
	
	echo "正常直流输出电压过高告警："$dc_voltage_output_higher
	echo  "$dc_voltage_output_higher"  >  dc_voltage_output_higher
	
	
	
	######################交流告警#############################
	
	basic.exe huawei.txt 5 100 20  $1
	recive_ac_alarm=$(cat receiveinfo)
	
	ac_voltage_input_over=0    ###0表示正常交流输入电压过高告警>275
	ac_voltage_input_lower=0    ###0表示正常交流输入电压过低告警<176
	ac_input_phase_lost=0    ###0表示正常交流输入缺相告警
	
	
	ac_voltage_input_diff1=${recive_ac_alarm:34:4}
	if [ "$ac_voltage_input_diff1" == "3032" ]; then
		ac_voltage_input_over=1;
	fi
	if [ "$ac_voltage_input_diff1" == "3031" ]; then
		ac_voltage_input_lower=1;
	fi
	if [ "$ac_voltage_input_diff1" == "3033" ]; then
		ac_input_phase_lost=1;
	fi
	
	ac_voltage_input_diff2=${recive_ac_alarm:38:4}
	if [ "$ac_voltage_input_diff2" == "3032" ]; then
			ac_voltage_input_over=1;
	fi
	if [ "$ac_voltage_input_diff2" == "3031" ]; then
		ac_voltage_input_lower=1;
	fi
	if [ "$ac_voltage_input_diff2" == "3033" ]; then
		ac_input_phase_lost=1;
	fi
	
	ac_voltage_input_diff3=${recive_ac_alarm:42:4}
	if [ "$ac_voltage_input_diff3" == "3032" ];then
			ac_voltage_input_over=1;
	fi
	if [ "$ac_voltage_input_diff3" == "3031" ];then
		ac_voltage_input_lower=1;
	fi
	if [ "$ac_voltage_input_diff3" == "3033" ];then
		ac_input_phase_lost=1;
	fi
	
	echo "正常交流输入电压过高告警："$ac_voltage_input_over
	echo "正常交流输入电压过低告警："$ac_voltage_input_lower
	echo "正常交流输入电压缺相："$ac_input_phase_lost
	
	echo  "$ac_voltage_input_over"  >  ac_voltage_input_over
	echo  "$ac_voltage_input_lower"  >  ac_voltage_input_lower
	echo  "$ac_input_phase_lost"  >  ac_input_phase_lost
	
	ac_input_stopped=0    ###0表示正常交流输入停电告警
	ac_input_stopped1=${recive_ac_alarm:78:4}
	if [ "$ac_input_stopped1" == "3834" ];then
		ac_input_stopped=1;
	fi
	
	echo "正常交流输入停电告警："$ac_input_stopped
	echo  "$ac_input_stopped"  >  ac_input_stopped

	lightning_arrester_alarm=0    ###0表示正常防雷器故障告警
	lightning_arrester_alarm1=${recive_ac_alarm:62:4}
	if [ "$lightning_arrester_alarm1" == "3831" ];then
		lightning_arrester_alarm=1;
	fi
	
	echo "正常防雷器故障告警："$lightning_arrester_alarm
	echo  "$lightning_arrester_alarm"  >  lightning_arrester_alarm
	
	
	
	#############################整流告警######################
	
	basic.exe huawei.txt 8 100 18 $1
	recive_rectifier_alarm=$(cat receiveinfo)
	
	rectifier_module_alarm=0    ###0表示正常整流模块故障告警
	rectifier_module_alarm1=${recive_rectifier_alarm:30:4}
	if [ "$rectifier_module_alarm1" == "3031" ]; then
		rectifier_module_alarm=1;
	fi
	
	echo "正常整流模块故障告警："$rectifier_module_alarm
	echo  "$rectifier_module_alarm"  >  rectifier_module_alarm
	
	configure_module_communication_status=0    ###整流模块通信状态
	configure_module_communication_status1=${recive_rectifier_alarm:38:4}
	if [ "$configure_module_communication_status1" == "3830" ];then
		configure_module_communication_status=1;
	fi
	
	echo "整流模块通信故障:"$configure_module_communication_status    ###整流模块通信状态
	
	echo  "$configure_module_communication_status"  >  configure_module_communication_status
	
	
	
	##########################################模块数量#######################################
	
	configure_module_number=1    ###正常配置模块数量
	if [ $configure_module_number == $(cat configure_module_number) ];then
	    echo 1  >  configure_module_number_update
	else
	    echo 0  >  configure_module_number_update
	fi
	echo  "$configure_module_number"  >  configure_module_number
	
	
	
######################################交流测量##################################################
	
	basic.exe huawei.txt 14 100 20  $1
	recive_ac_analog_output=$(cat receiveinfo)
	
	switch_power_voltage_A=220    ###正常开关电源交流输入相电压Ua
	switch_power_voltage_ascii_a=${recive_ac_analog_output:34:16}
	
	switch_power_voltage_A=$(DataF_convert_Uabc  "$switch_power_voltage_ascii_a")
	
	echo "正常开关电源交流输入相电压Ua："$switch_power_voltage_A
	if [ $switch_power_voltage_A == $(cat switch_power_voltage_A) ];then
	    echo 1  >  switch_power_voltage_A_update
	else
	    echo 0  >  switch_power_voltage_A_update
	fi
	echo  "$switch_power_voltage_A"  >  switch_power_voltage_A
	
	switch_power_voltage_B=220    ###正常开关电源交流输入相电压Ub
	switch_power_voltage_ascii_b=${recive_ac_analog_output:50:16}
	switch_power_voltage_B=$(DataF_convert_Uabc  "$switch_power_voltage_ascii_b")
	
	echo "正常开关电源交流输入相电压Ub："$switch_power_voltage_B
	if [ $switch_power_voltage_B == $(cat switch_power_voltage_B) ];then
	    echo 1  >  switch_power_voltage_B_update
	else
	    echo 0  >  switch_power_voltage_B_update
	fi
	echo  "$switch_power_voltage_B"  >  switch_power_voltage_B
	
	switch_power_voltage_C=220    ###正常开关电源交流输入相电压Uc
	switch_power_voltage_ascii_c=${recive_ac_analog_output:66:16}
	switch_power_voltage_C=$(DataF_convert_Uabc  "$switch_power_voltage_ascii_c")
	
	echo "正常开关电源交流输入相电压Uc："$switch_power_voltage_C
	if [ $switch_power_voltage_C == $(cat switch_power_voltage_C) ];then
	    echo 1  >  switch_power_voltage_C_update
	else
	    echo 0  >  switch_power_voltage_C_update
	fi
	echo  "$switch_power_voltage_C"  >  switch_power_voltage_C
	

    ###########################直流测量############################################
	###############################################################################
	
	basic.exe huawei.txt 17 100 20 $1
	recive_dc_analog_output=$(cat receiveinfo)
	
	switch_power_dc_voltage=0   ###正常直流电压
	switch_power_dc_voltage_ascii=${recive_dc_analog_output:30:16}
	switch_power_dc_voltage=$(DataF_convert_Uabc  "$switch_power_dc_voltage_ascii")
	
	echo "正常直流电压："$switch_power_dc_voltage
	if [ $switch_power_dc_voltage == $(cat switch_power_dc_voltage) ];then
	    echo 1  >  switch_power_dc_voltage_update
	else
	    echo 0  >  switch_power_dc_voltage_update
	fi
	echo  "$switch_power_dc_voltage"  >  switch_power_dc_voltage
	
	switch_power_dc_current=0    ###正常直流负载总电流
	switch_power_dc_current_ascii=${recive_dc_analog_output:46:16}
	switch_power_dc_current=$(DataF_convert_Uabc  "$switch_power_dc_current_ascii")
	
	echo "正常直流负载总电流："$switch_power_dc_current
	if [ $switch_power_dc_current == $(cat switch_power_dc_current) ];then
	    echo 1  >  switch_power_dc_current_update
	else
	    echo 0  >  switch_power_dc_current_update
	fi
	echo  "$switch_power_dc_current"  >  switch_power_dc_current
	
	spower_group1_current=0    ###正常电池组电流
	spower_group1_current_ascii=${recive_dc_analog_output:794:16}
	spower_group1_current=$(DataF_convert_Uabc  "$spower_group1_current_ascii")
	
	echo "正常电池组1电流："$spower_group1_current
	if [ $spower_group1_current == $(cat spower_group1_current) ];then
	    echo 1  >  spower_group1_current_update
	else
	    echo 0  >  spower_group1_current_update
	fi
	echo  "$spower_group1_current"  >  spower_group1_current
	
	
	
	#################################整流测量##########################
	##############################################################################
	basic.exe huawei.txt 20 100 18 $1
	recive_rectifier_analog_output=$(cat receiveinfo)
	
	rectifier_module_current=0    ###正常整流模块电流
	rectifier_module_current_ascii=${recive_rectifier_analog_output:30:16}
	rectifier_module_current=$(DataF_convert_Uabc  "$rectifier_module_current_ascii")
	
	echo "正常整流模块电流："$rectifier_module_current
	if [ $rectifier_module_current == $(cat rectifier_module_current) ];then
	    echo 1  >  rectifier_module_current_update
	else
	    echo 0  >  rectifier_module_current_update
	fi
	echo  "$rectifier_module_current"  >  rectifier_module_current
	
	rectifier_module_temperature=20    ###正常整流模块温度
	rectifier_module_temperature_ascii=${recive_rectifier_analog_output:82:16}
	rectifier_module_temperature=$(DataF_convert_Uabc  "$rectifier_module_temperature_ascii")
	
	echo "正常整流模块温度："$rectifier_module_temperature
	if [ $rectifier_module_temperature == $(cat rectifier_module_temperature) ];then
	    echo 1  >  rectifier_module_temperature_update
	else
	    echo 0  >  rectifier_module_temperature_update
	fi
	echo  "$rectifier_module_temperature"  >  rectifier_module_temperature
	

