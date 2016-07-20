#!/bin/bash
cd /home/pi/UpdateInfo
##############更新传感器文件中的信息
###########################开关电源信息更新#####################开关电源信息更新#####################
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

function system_analogs()
{
	input1=$(echo $1 | tr a-z A-Z) 
	io_binary_a=$(hex8_binary16   "$input1")
	symbol_a=${io_binary_a:0:1}
	order_code_a=${io_binary_a:1:8}
	tail_code_a=${io_binary_a:9:23}
	output=$(convert_Uabc_32   "$symbol_a"   "$order_code_a"  "$tail_code_a")
	echo "$output"

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
	basic.exe zhongheng.txt 2 100 11 $1
	battery_melt_alarm_recive=$(cat receiveinfo)
	battery_melt_alarm_hex16=${battery_melt_alarm_recive:14:2}
	
	###recive_dc_alarm_hex16在0-4之间为报警
	if [ ${battery_melt_alarm_hex16:1:1} -lt "5" ];then
		battery_melt_alarm=1
	fi
	
	echo "电池熔丝故障："$battery_melt_alarm
	echo  "$battery_melt_alarm"  >  battery_melt_alarm

	
	charge_current_over=0    ###0表示正常电池充电过流告警
	basic.exe zhongheng.txt 5 100 11 $1
	charge_current_over_recive=$(cat receiveinfo)
	charge_current_over_hex16=${charge_current_over_recive:14:2}
	
	###charge_current_over_recive在0-4之间为报警
	if [ ${charge_current_over_hex16:1:1} -lt "5" ];then
		charge_current_over=1
	fi
	
	echo "电池充电过流告警："$charge_current_over
	echo  "$charge_current_over"  >  charge_current_over
	
	
	charge_temperature_over=0    ###0表示正常电池温度过高告警>32
	basic.exe zhongheng.txt 8 100 11 $1
	charge_temperature_over_recive=$(cat receiveinfo)
	charge_temperature_over_hex16=${charge_temperature_over_recive:14:2}
	if [ ${charge_temperature_over_hex16:1:1} -lt "5" ];then
		charge_temperature_over=1
	fi
	
	echo "正常电池温度过高告警："$charge_temperature_over
	echo  "$charge_temperature_over"  >  charge_temperature_over
	
	
	
	supply_alarm=0    ###0表示正常系统处于蓄电池供电状态
	basic.exe zhongheng.txt 11 100 11 $1
	supply_alarm_recive=$(cat receiveinfo)
	supply_alarm_recive_hex16=${supply_alarm_recive:14:2}
	if [ ${supply_alarm_recive_hex16:1:1} -lt "5" ];then
		supply_alarm=1
	fi
	
	echo "蓄电池供电状态故障："$supply_alarm
	echo  "$supply_alarm"  >  supply_alarm
	
	
	dc_voltage_output_lower=0    ###0表示正常直流输出电压过低告警<47
	
	echo  "$dc_voltage_output_lower"  >  dc_voltage_output_lower
	
	dc_voltage_output_higher=0    ###0表示正常直流输出电压过高告警>57.5
	
	echo  "$dc_voltage_output_higher"  >  dc_voltage_output_higher
	
	
	
	######################交流告警#############################
	ac_voltage_input_over=0
	basic.exe zhongheng.txt 20 100 11 $1
	ac_voltage_input_over_recive=$(cat receiveinfo)
	ac_voltage_input_over_hex16=${ac_voltage_input_over_recive:14:2}
	if [ ${ac_voltage_input_over_hex16:1:1} -lt "5" ];then
		ac_voltage_input_over=1
	fi
	
	echo "正常交流输入电压过高告警："$ac_voltage_input_over
	echo  "$ac_voltage_input_over"  >  ac_voltage_input_over
	
	
	ac_voltage_input_lower=0
	basic.exe zhongheng.txt 23 100 11 $1
	ac_voltage_input_lower_recive=$(cat receiveinfo)
	ac_voltage_input_lower_hex16=${ac_voltage_input_lower_recive:14:2}
	if [ ${ac_voltage_input_lower_hex16:1:1} -lt "5" ];then
		ac_voltage_input_lower=1
	fi
	echo "正常交流输入电压过低告警："$ac_voltage_input_lower
	echo  "$ac_voltage_input_lower"  >  ac_voltage_input_lower
	
	
	ac_input_phase_lost=0
	basic.exe zhongheng.txt 29 100 11 $1
	ac_input_phase_lost_recive=$(cat receiveinfo)
	ac_input_phase_lost_hex16=${ac_input_phase_lost_recive:14:2}
	if [ ${ac_input_phase_lost_hex16:1:1} -lt "5" ];then
		ac_input_phase_lost=1
	fi
	echo "正常交流输入电压缺相："$ac_input_phase_lost
	echo  "$ac_input_phase_lost"  >  ac_input_phase_lost
	
	

	
	
	lightning_arrester_alarm=0    ###0表示正常防雷器故障告警
	echo  "$lightning_arrester_alarm"  >  lightning_arrester_alarm
	
	
	
	#############################整流告警######################
	rectifier_module_alarm=0    ###0表示正常整流模块故障告警
	basic.exe zhongheng.txt 35 100 11 $1
	rectifier_module_alarm_recive=$(cat receiveinfo)
	rectifier_module_alarm_hex16=${rectifier_module_alarm_recive:14:2}
	if [ ${rectifier_module_alarm_hex16:1:1} -lt "5" ];then
		rectifier_module_alarm=1
	fi
	echo "正常整流模块故障告警："$rectifier_module_alarm
	echo  "$rectifier_module_alarm"  >  rectifier_module_alarm
	
	
	configure_module_communication_status=0    ###整流模块通信状态
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
	basic.exe zhongheng.txt 41 100 10 $1
	recive_analog_output=$(cat receiveinfo)
	
	switch_power_voltage_A=220    ###正常开关电源交流输入相电压Ua
	switch_power_voltage_hex16_A=${recive_analog_output:20:8}
	echo "switch_power_voltage_hex16_A:"$switch_power_voltage_hex16_A
	switch_power_voltage_A=$(system_analogs "$switch_power_voltage_hex16_A")
	
	echo "正常开关电源交流输入相电压Ua："$switch_power_voltage_A
	if [ $switch_power_voltage_A == $(cat switch_power_voltage_A) ];then
	    echo 1  >  switch_power_voltage_A_update
	else
	    echo 0  >  switch_power_voltage_A_update
	fi
	echo  "$switch_power_voltage_A"  >  switch_power_voltage_A
	
	switch_power_voltage_B=220    ###正常开关电源交流输入相电压Ub
	switch_power_voltage_hex16_B=${recive_analog_output:28:8}
	switch_power_voltage_B=$(system_analogs "$switch_power_voltage_hex16_B")
	
	echo "正常开关电源交流输入相电压Ub："$switch_power_voltage_B
	if [ $switch_power_voltage_B == $(cat switch_power_voltage_B) ];then
	    echo 1  >  switch_power_voltage_B_update
	else
	    echo 0  >  switch_power_voltage_B_update
	fi
	echo  "$switch_power_voltage_B"  >  switch_power_voltage_B
	
	switch_power_voltage_C=220    ###正常开关电源交流输入相电压Uc
	switch_power_voltage_hex16_C=${recive_analog_output:36:8}
	switch_power_voltage_C=$(system_analogs "$switch_power_voltage_hex16_C")
	
	echo "正常开关电源交流输入相电压Uc："$switch_power_voltage_C
	if [ $switch_power_voltage_C == $(cat switch_power_voltage_C) ];then
	    echo 1  >  switch_power_voltage_C_update
	else
	    echo 0  >  switch_power_voltage_C_update
	fi
	
	echo "正常交流输入停电告警"$ac_input_stopped
	
	echo  "$ac_input_stopped"  >  ac_input_stopped
    ###########################直流测量############################################
	###############################################################################
	
	switch_power_dc_voltage=0   ###正常直流电压
	switch_power_dc_voltage_hex16=${recive_analog_output:44:8}
	switch_power_dc_voltage=$(system_analogs "$switch_power_dc_voltage_hex16")
	
	echo "正常直流电压："$switch_power_dc_voltage
	if [ $switch_power_dc_voltage == $(cat switch_power_dc_voltage) ];then
	    echo 1  >  switch_power_dc_voltage_update
	else
	    echo 0  >  switch_power_dc_voltage_update
	fi
	echo  "$switch_power_dc_voltage"  >  switch_power_dc_voltage
	
	switch_power_dc_current=0    ###正常直流负载总电流
	switch_power_dc_current_hex16=${recive_analog_output:52:8}
	switch_power_dc_current=$(system_analogs "$switch_power_dc_current_hex16")
	
	echo "正常直流负载总电流："$switch_power_dc_current
	if [ $switch_power_dc_current == $(cat switch_power_dc_current) ];then
	    echo 1  >  switch_power_dc_current_update
	else
	    echo 0  >  switch_power_dc_current_update
	fi
	echo  "$switch_power_dc_current"  >  switch_power_dc_current
	
	spower_group1_current=0    ###正常电池组1电流
	spower_group1_current_hex16=${recive_analog_output:60:8}
	spower_group1_current=$(system_analogs "$spower_group1_current_hex16")
	
	echo "正常电池组1电流："$spower_group1_current
	if [ $spower_group1_current == $(cat spower_group1_current) ];then
	    echo 1  >  spower_group1_current_update
	else
	    echo 0  >  spower_group1_current_update
	fi
	echo  "$spower_group1_current"  >  spower_group1_current
	
	
	
	#################################整流测量##########################
	##############################################################################
	rectifier_module_current=0    ###正常整流模块电流
	rectifier_module_current_hex16=${recive_analog_output:68:8}
	rectifier_module_current=$(system_analogs "$rectifier_module_current_hex16")
	
	echo "正常整流模块电流："$rectifier_module_current
	if [ $rectifier_module_current == $(cat rectifier_module_current) ];then
	    echo 1  >  rectifier_module_current_update
	else
	    echo 0  >  rectifier_module_current_update
	fi
	echo  "$rectifier_module_current"  >  rectifier_module_current
	
	rectifier_module_temperature=20    ###正常整流模块温度
	echo "正常整流模块温度："$rectifier_module_temperature
	if [ $rectifier_module_temperature == $(cat rectifier_module_temperature) ];then
	    echo 1  >  rectifier_module_temperature_update
	else
	    echo 0  >  rectifier_module_temperature_update
	fi
	echo  "$rectifier_module_temperature"  >  rectifier_module_temperature
	

