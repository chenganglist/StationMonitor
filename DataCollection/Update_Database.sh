#!/bin/bash
cd /home/pi/UpdateInfo
#####更新数据库数据####
function update_data()
{
   	sql="update TSemaphore set MeasureVal='$1' where ID='$2' and DeviceID='$3'"
	echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db 
}

####添加信息到历史记录####
function insert_history()
{
	sql="insert into TSemaphore_history (Time , ID , MeasureVal , DeviceID , Explain , Type , Status) values ('$1' ,'$2','$3','$4','$5','$6','$7')"
	echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db 
}

####统计数据库的记录条数#####
function records_number()
{
    sql="select count(*)  from TSemaphore_history"
	echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db
}

function get_time()
{
	time1=$(date +%Y-%m-%d)
	time2=$(date +%T)
	time="$time1"" ""$time2"
	echo $time
}


function history_bak()
{
	if [ ! -f "last_time_database_detect" ];then
			date +%s  >  last_time_database_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_database_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_database_detect
	fi
	if [ $time_interval -ge 1800 ];then
		history_num=$(records_number) 
		if [ $history_num -ge 40000 ];then
			touch  /home/pi/www/services/history_bak.db
			cp   /home/pi/www/services/history.db   /home/pi/www/services/history_bak.db
			sql="delete  from TSemaphore_history"
			echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db
		fi
	fi
}


function environment()
{
	if [ ! -f "last_time_env_detect" ];then
		date +%s  >  last_time_env_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_env_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_env_detect
	fi
	if [ $time_interval -ge 10 ];then 
		date +%s  >  last_time_env_detect
		
		if [ $(cat decimal_temperature1_update) == 1 ];then
		   update_data  "$(cat decimal_temperature1)"   "0418101001"  "42020141800003"
		fi
		
		if [ $(cat decimal_humidity1_update) == 1 ];then
		   update_data  "$(cat decimal_humidity1)"   "0418102001"  "42020141800003"
		fi
		
		if [ $(cat decimal_temperature2_update) == 1 ];then
		   update_data  "$(cat decimal_temperature2)"   "0418101001"  "42020141800004"
		fi
		
		if [ $(cat decimal_humidity2_update) == 1 ];then
		   update_data  "$(cat decimal_humidity2)"   "0418102001"  "42020141800004"
		fi
	
		if [ $(cat io_smoke1_update) == 1 ];then
		   update_data  "$(cat io_smoke1)"  "0418002001"   "42020141800003"  
		fi
		
		if [ $(cat io_smoke2_update) == 1 ];then
		   update_data  "$(cat io_smoke2)"  "0418002001"   "42020141800004"    
		fi
		
		if [ $(cat io_smoke3_update) == 1 ];then
		   update_data  "$(cat io_smoke3)"  "0418002001"   "42020141800005"     
		fi
		
		if [ $(cat io_smoke4_update) == 1 ];then
		   update_data  "$(cat io_smoke4)"  "0418002001"   "42020141800006"     
		fi
		
		if [ $(cat infared1_update) == 1 ];then
		   update_data  "$(cat infared1)"  "0418003001"   "42020141800002"   
		fi
		
		if [ $(cat infared2_update) == 1 ];then
		   update_data  "$(cat infared2)"  "0418003001"   "42020141800003" 
		fi
		 
		if [ $(cat soak_resist1_update) == 1 ];then
		   update_data  "$(cat soak_resist1)"  "0418009001"   "42020141800001"	
		fi
		
		if [ $(cat soak_resist2_update) == 1 ];then
		   update_data  "$(cat soak_resist2)"  "0418009001"   "42020141800003"	
		fi
		
		if [ $(cat soak_resist3_update) == 1 ];then
		   update_data  "$(cat soak_resist3)"  "0418009001"   "42020141800004"	
		fi
		
		if [ $(cat soak_resist4_update) == 1 ];then
		   update_data  "$(cat soak_resist4)"  "0418009001"   "42020141800005"	
		fi
		
		if [ $(cat door_magnetic1_update) == 1 ];then
		   update_data  "$(cat door_magnetic1)"  "0417005001"   "42020141850005"
		fi
		
		if [ $(cat door_magnetic2_update) == 1 ];then
		   update_data  "$(cat door_magnetic2)"  "0417005001"   "42020141850006"
		fi
		
		if [ $(cat door_magnetic3_update) == 1 ];then
		   update_data  "$(cat door_magnetic3)"  "0417005001"   "42020141850007"
		fi
		
		if [ $(cat door_magnetic4_update) == 1 ];then
		   update_data  "$(cat door_magnetic4)"  "0417005001"   "42020141850008"
		fi	
		
		if [ $(cat forward_half_battery_voltage1_update) == 1 ];then
		   update_data  "$(cat forward_half_battery_voltage1)"  "0407002001"   "42020140700004"
		fi
		
		if [ $(cat backward_half_battery_voltage1) == 1 ];then
		   update_data  "$(cat backward_half_battery_voltage1)"  "0407106001"   "42020140700004"
		fi
		
		if [ $(cat total_battery_group_voltage1) == 1 ];then
		   update_data  "$(cat total_battery_group_voltage1)"  "0407107001"   "42020140700004"
		fi
		
		if [ $(cat forward_half_battery_voltage2_update) == 1 ];then
		   update_data  "$(cat forward_half_battery_voltage2)"  "0407002001"   "42020140700004"
		fi
		
		if [ $(cat backward_half_battery_voltage2) == 1 ];then
		   update_data  "$(cat backward_half_battery_voltage2)"  "0407106001"   "42020140700004"
		fi
		
		if [ $(cat total_battery_group_voltage2) == 1 ];then
		   update_data  "$(cat total_battery_group_voltage2)"  "0407107001"   "42020140700004"
		fi
		
	fi
	
	###############每半小时存入一组数据到历史数据库#######################
	if [ ! -f "last_time_env_his" ];then
			date +%s  >  last_time_env_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_env_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_env_his
	fi
	if [ $time_interval -ge 1800 ];then
		date +%s  >  last_time_env_his
		insert_history   "$time"   "0418101001"      "$(cat decimal_temperature1)"   "42020141800003"    "机房温度1"     "3"    "0"
		insert_history   "$time"   "0418102001"      "$(cat decimal_humidity1)"   "42020141800003"    "机房湿度1"     "3"    "0"
		insert_history   "$time"   "0418101001"      "$(cat decimal_temperature2)"   "42020141800004"    "机房温度2"     "3"    "0"
		insert_history   "$time"   "0418102001"      "$(cat decimal_humidity2)"   "42020141800004"    "机房湿度2"     "3"    "0"

		insert_history   "$time"   "0418002001"      "$(cat io_smoke1)"    "42020141800003"     "烟感1"       "2"    "1"    
		insert_history   "$time"   "0418002001"      "$(cat io_smoke2)"    "42020141800004"     "烟感2"       "2"    "1"    
		insert_history   "$time"   "0418002001"      "$(cat io_smoke3)"    "42020141800005"     "烟感3"       "2"    "1"    
		insert_history   "$time"   "0418002001"      "$(cat io_smoke4)"    "42020141800006"     "烟感4"       "2"    "1"    
	
		insert_history   "$time"  "0418003001"      "$(cat infared1)"   "42020141800002"       "红外1"     "2"    "1"    
		insert_history   "$time"  "0418003001"      "$(cat infared2)"   "42020141800003"       "红外2"     "2"    "1"    
	
		insert_history    "$time"   "0418001001"     "$(cat soak_resist1)"   "42020141800001"    "水浸1"     "2"     "1"   ######
		insert_history    "$time"   "0418001001"     "$(cat soak_resist2)"   "42020141800003"    "水浸2"     "2"     "1"   ######
		insert_history    "$time"   "0418001001"     "$(cat soak_resist3)"   "42020141800004"    "水浸3"     "2"     "1"   ######
		insert_history    "$time"   "0418001001"     "$(cat soak_resist4)"   "42020141800005"    "水浸4"     "2"     "1"   ######
		
		insert_history   "$time"  "0417005001"      "$(cat door_magnetic1)"   "42020141850005"       "门磁1"     "2"    "1"    
		insert_history    "$time"   "0417005001"     "$(cat door_magnetic2)"   "42020141850006"    "门磁2"     "2"     "1"  
		insert_history   "$time"  "0417005001"      "$(cat door_magnetic3)"   "42020141850007"       "门磁3"     "2"    "1"    
		insert_history    "$time"   "0417005001"     "$(cat door_magnetic4)"   "42020141850008"    "门磁4"     "2"     "1"  
	fi
}


function switch_power()
{
	if [ ! -f "last_time_switch_power_detect" ];then
			date +%s  >  last_time_switch_power_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_switch_power_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_switch_power_detect
	fi

	if [ $time_interval -ge 60 ];then
		date +%s  >  last_time_switch_power_detect
		if [ $(cat configure_module_number_update) == 1 ];then
		   update_data  "$(cat configure_module_number)"   "0406123001"   "42020140600002"
		fi
		if [ $(cat switch_power_voltage_A_update) == 1  ];then
		   update_data  "$(cat switch_power_voltage_A)"   "0406101001"   "42020140600002"
		fi
		if [ $(cat switch_power_voltage_B_update) == 1 ];then
		   update_data  "$(cat switch_power_voltage_B)"   "0406102001"   "42020140600002"
		fi
		if [ $(cat switch_power_voltage_C_update) == 1 ];then
		   update_data  "$(cat switch_power_voltage_C)"   "0406103001"   "42020140600002"
		fi
		if [ $(cat switch_power_direct_voltage_update) == 1 ];then
		   update_data  "$(cat switch_power_direct_voltage)"   "0406111001"   "42020140600002"
		fi
		if [ $(cat switch_power_direct_current_update) == 1  ];then
		   update_data  "$(cat switch_power_direct_current)"   "0406112001"   "42020140600002"
		fi
		if [ $(cat rectifier_module_current_update) == 1  ];then
		   update_data  "$(cat rectifier_module_current)"   "0406113001"   "42020140600002"
		fi
		if [ $(cat rectifier_module_temperature_update) == 1 ];then
		   update_data  "$(cat rectifier_module_temperature)"   "0406114001"   "42020140600002"
		fi
		if [ $(cat spower_group_current_update) == 1 ];then
		   update_data  "$(cat spower_group_current)"   "0406115001"   "42020140600002"
		fi
	fi
	
	if [ ! -f "last_time_switch_power_his" ];then
			date +%s  >  last_time_switch_power_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_switch_power_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_switch_power_his
	fi
	if [ $time_interval -ge 1800 ];then
		echo $current_time  >  last_time_switch_power_his
		insert_history    "$time"   "0406123001"      "$(cat configure_module_number)"    "42020140600002"  "电源配置模块数目"     "3"       "0"
		insert_history    "$time"   "0406101001"      "$(cat switch_power_voltage_A)"    "42020140600002"  "开关电源交流输入相电压Ua"     "3"       "0"
		insert_history    "$time"   "0406102001"      "$(cat switch_power_voltage_B)"   "42020140600002"  "开关电源交流输入相电压Ub"     "3"       "0"
		insert_history    "$time"   "0406103001"      "$(cat switch_power_voltage_C)"   "42020140600002"   "开关电源交流输入相电压Uc"     "3"       "0"
		insert_history    "$time"   "0406111001"      "$(cat switch_power_direct_voltage)"    "42020140600002"   "直流电压"     "3"       "0"
		insert_history    "$time"   "0406112001"      "$(cat switch_power_direct_current)"    "42020140600002"   "直流负载总电流"     "3"       "0"
		insert_history    "$time"   "0406113001"      "$(cat rectifier_module_current)"     "42020140600002"    "整流模块电流"     "3"       "0"
		insert_history    "$time"   "0406114001"      "$(cat rectifier_module_temperature)"      "42020140600002"   "整流模块温度"     "3"       "0"
		insert_history    "$time"   "0406115001"      "$(cat spower_group_current)"      "42020140600002"   "电池组电流"     "3"       "0"
	fi
}


function battery_group()
{
	if [ ! -f "last_time_battery_group_detect" ];then
			date +%s  >  last_time_battery_group_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_battery_group_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_battery_group_detect
	fi
	if [ $time_interval -ge 60 ];then
		date +%s  >  last_time_battery_group_detect
		if [ $(cat total_battery_group_voltage1_update) == 1 ];then
		   update_data  "$(cat total_battery_group_voltage1)"   "0407102001"   "42020140600004"
		fi
		if [ $(cat forward_half_battery_voltage1_update) == 1 ];then
		   update_data  "$(cat forward_half_battery_voltage1)"   "0407106001"   "42020140600004" 
		fi
		if [ $(cat backward_half_battery_voltage1_update) == 1 ];then
		   update_data  "$(cat backward_half_battery_voltage1)"   "0407107001"   "42020140600004"
		fi 
		
		if [ $(cat total_battery_group_voltage2_update) == 1 ];then
		   update_data  "$(cat total_battery_group_voltage2)"   "0407102001"   "42020140600005"
		fi
		if [ $(cat forward_half_battery_voltage2_update) == 1 ];then
		   update_data  "$(cat forward_half_battery_voltage2)"   "0407106001"   "42020140600005" 
		fi
		if [ $(cat backward_half_battery_voltage2_update) == 1 ];then
		   update_data  "$(cat backward_half_battery_voltage2)"   "0407107001"   "42020140600005"
		fi 
	fi
	if [ ! -f "last_time_battery_group_his" ];then
			date +%s  >  last_time_battery_group_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_battery_group_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_battery_group_his
	fi
	if [ $time_interval -ge 1800 ];then
		echo $current_time  >  last_time_battery_group_his
		insert_history    "$time"   "0407102001"      "$(cat total_battery_group_voltage1)"   "42020140600004"      "蓄电池组1总电压"     "3"       "0"
		insert_history    "$time"   "0407106001"      "$(cat forward_half_battery_voltage1)"   "42020140600004"      "蓄电池组1前半组电压"     "3"       "0"
		insert_history    "$time"   "0407107001"      "$(cat backward_half_battery_voltage1)"   "42020140600004"      "蓄电池组1后半组电压"     "3"       "0"
		insert_history    "$time"   "0407102001"      "$(cat total_battery_group_voltage2)"   "42020140600005"      "蓄电池组2总电压"     "3"       "0"
		insert_history    "$time"   "0407106001"      "$(cat forward_half_battery_voltage2)"   "42020140600005"      "蓄电池组2前半组电压"     "3"       "0"
		insert_history    "$time"   "0407107001"      "$(cat backward_half_battery_voltage2)"   "42020140600005"      "蓄电池组2后半组电压"     "3"       "0"
	fi
}


function air_condition()
{
	if [ ! -f "normal_air_conditioner_detect" ];then
			date +%s  >  normal_air_conditioner_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat normal_air_conditioner_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  normal_air_conditioner_detect
	fi
	if [ $time_interval -ge 60 ];then
		date +%s  >  normal_air_conditioner_detect
		if [ $(cat return_air_temperature_update) == 1 ];then
		   update_data  "$(cat return_air_temperature)"   "0415102001"   "42020141500003"
		fi
		
		if [ $(cat normal_air_temperature_setval_update) == 1 ];then
		   update_data  "$(cat normal_air_temperature_setval)"   "0415301001"   "42020141500003"
		fi
	fi	
	
	if [ ! -f "last_time_battery_group_his" ];then
			date +%s  >  last_time_battery_group_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_battery_group_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_battery_group_his
	fi
	if [ $time_interval -ge 1800 ];then
		echo $current_time  >  last_time_battery_group_his
		insert_history    "$time"   "0415102001"      "$(cat return_air_temperature)"   "42020141500003"    "空调回风温度"     "3"       "0"
		insert_history    "$time"   "0415301001"      "$(cat normal_air_temperature_setval)"   "42020141500003"     "运行温度设定值"     "3"       "5"
	fi
}


function door_guard()
{
	if [ ! -f "guard_system_detect" ];then
			date +%s  >  guard_system_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat guard_system_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  guard_system_detect
	fi
	if [ $time_interval -ge 60 ];then
		date +%s  >  guard_system_detect
		if [ $(cat guard_system_door_status_update) == 1 ];then
			update_data  "$(cat guard_system_door_status)"   "0417005001"   "42020141900002"
		fi
	fi
	
	if [ ! -f "last_time_guard_his" ];then
			date +%s  >  last_time_guard_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_guard_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_guard_his
	fi
	if [ $time_interval -ge 1800 ];then
		echo $current_time  >  last_time_guard_his
		insert_history    "$time"    "0417005001"   "$(cat guard_system_door_status)"    "42020141900002"     "门禁系统门磁开关状态"     "2"       "0"
	fi
}


function elec_meter()
{
	if [ ! -f "last_time_elec_detect" ];then
			date +%s  >  last_time_elec_detect
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_elec_detect)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_elec_detect
	fi
	if [ $time_interval -ge 60 ];then
		date +%s  >  last_time_elec_detect
		if [ $(cat decimal_A_phase_voltage_update) == 1 ];then
			update_data  "$(cat decimal_A_phase_voltage)"   "0416104001"   "42020141700002"	
		fi
		if [ $(cat decimal_B_phase_voltage_update) == 1 ];then
			update_data  "$(cat decimal_B_phase_voltage)"   "0416105001"   "42020141700002"
		fi
		if [ $(cat decimal_C_phase_voltage_update) == 1 ];then
			update_data  "$(cat decimal_C_phase_voltage)"  "0416106001"   "42020141700002"	
		fi
	fi
	
	if [ ! -f "last_time_elec_his" ];then
			date +%s  >  last_time_elec_his
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_elec_his)" | bc)
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_elec_his
	fi
	if [ $time_interval -ge 1800 ];then
		echo $current_time  >  last_time_elec_his
		insert_history    "$time"   "0416104001"      "$(cat decimal_A_phase_voltage)"   "42020141700002"    "A相电压"     "3"       "0"
		insert_history    "$time"   "0416105001"      "$(cat decimal_B_phase_voltage)"   "42020141700002"     "B相电压"     "3"       "0"
		insert_history    "$time"   "0416106001"      "$(cat decimal_C_phase_voltage)"   "42020141700002"    "C相电压"     "3"       "0"
	fi
}

####################################################################################################################
while [[ 1 ]];do  ###循环定时读取数据
	###检测数据库####
	history_bak
    ###机房环境数据###
	environment  
	###电表参数###
	elec_meter
	####普通空调####
	air_condition
	####门禁#####
	door_guard
	####开关电源####
	switch_power
	####蓄电池####
	battery_group
	sleep 5
	echo "One Circle database update finished"	
done
