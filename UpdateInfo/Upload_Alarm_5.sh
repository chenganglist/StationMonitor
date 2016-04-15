#!/bin/bash
cd /home/pi/UpdateInfo

sql="select FsuId from FSUINFO"
FsuId_All=$(echo "$sql;" | sqlite3 /home/pi/www/services/FSUINFO.db)


#####################上传告警信息#########################
###################添加XML报警字段########################
######################添加信息到历史记录#####################################
function insert_history()
{
	sql="insert into TSemaphore_history (Time , ID , MeasureVal , DeviceID , Explain , Type , Status) values ('$1' ,'$2','$3','$4','$5','$6','$7')"
	echo  "$sql;"  |  sqlite3  /home/pi/www/services/history.db 
}


function add_warning()
{
	SerialNo="$1";  ID="$2";   FSUID="$3";   DeviceID="$4";
	AlarmTime="$5";   AlarmLevel="$6";    AlarmFlag="$7";   AlarmDesc="$8";  
	echo     "<TAlarm>"  >>  Send_Alarm.xml
	echo     "<SerialNo>$SerialNo</SerialNo>"  >>  Send_Alarm.xml
	echo     "<Id>$ID</Id>"  >>  Send_Alarm.xml
	echo     "<DeviceId>$DeviceID</DeviceId>"  >>  Send_Alarm.xml
	echo     "<DeviceCode>$DeviceID</DeviceCode>"  >>  Send_Alarm.xml
	echo     "<AlarmTime>$AlarmTime</AlarmTime>"  >>  Send_Alarm.xml
	echo     "<FsuId>$FSUID</FsuId>"  >>  Send_Alarm.xml
	echo     "<FsuCode>$FSUID</FsuCode>"  >>  Send_Alarm.xml
	echo     "<AlarmLevel>$AlarmLevel</AlarmLevel>"  >>  Send_Alarm.xml
	echo     "<AlarmFlag>$AlarmFlag</AlarmFlag>"  >>  Send_Alarm.xml
	echo     "<AlarmDesc>$AlarmDesc</AlarmDesc>"  >>  Send_Alarm.xml
	echo     "</TAlarm>"  >>  Send_Alarm.xml
}

#####################添加XML报警头#######################
function add_warning_head()
{
	echo     "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > Send_Alarm.xml
	echo     "<Request>"  >>  Send_Alarm.xml
	echo     "<PK_Type>"  >>  Send_Alarm.xml
	echo     "<Name>SEND_ALARM</Name>"   >>  Send_Alarm.xml
	echo     "<Code>501</Code>"  >>  Send_Alarm.xml
	echo     "</PK_Type>"  >>  Send_Alarm.xml
	echo     "<Info>"  >>  Send_Alarm.xml
	echo     "<Values>"  >>  Send_Alarm.xml
	echo     "<TAlarmList>"  >>  Send_Alarm.xml
}

#####################添加XML报警尾#######################
function add_warning_tail()
{
	echo     "</TAlarmList>"  >>  Send_Alarm.xml
	echo     "</Values>"  >>  Send_Alarm.xml
	echo     "</Info>"  >>  Send_Alarm.xml
	echo     "</Request>"   >>  Send_Alarm.xml
}

function get_time()
{
	time1=$(date +%Y-%m-%d)
	time2=$(date +%T)
	time="$time1"" ""$time2"
	echo $time
}


infared1_Id="0418003001"
infared1DeviceId="42020141800002"
#######红外告警
function infared1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "infared1_alarm_count" ];then
			echo  "0"   >   infared1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "infared1_open_time" ];then
			date +%s   >   infared1_open_time
	fi
	
	if [ "$(cat infared1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################红外检测到物体活动########################
		if [ $(cat infared1) -eq 1 ];then
			echo  "1"   >   infared1_begin
			echo $((1+$(cat infared1_alarm_count))) >  infared1_alarm_count
			if [ $(cat infared1_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  infared1_serial_high_frequency
				insert_history   "$time"   "$infared1_Id"      "$(cat infared1)"   "$infared1DeviceId"    "红外1检测到物体活动"      "2"    "3"
				add_warning   "$(cat infared1_serial_high_frequency)"    "$infared1_Id"    "$FsuId_All"     "$infared1DeviceId"     "$time"   "3"   "BEGIN"    "高频告警：红外检测到物体活动"
				echo "0"  >  infared1_alarm_count   #########重新计数
				echo "1"  >  infared1_close    ##########关闭告警
				date +%s  >  infared1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  infared1_serial
				insert_history   "$time"   "$infared1_Id"      "$(cat infared1)"   "$infared1DeviceId"    "红外1检测到物体活动"      "2"    "3"
				add_warning   "$(cat infared1_serial)"    "$infared1_Id"    "$FsuId_All"      "$infared1DeviceId"    "$time"   "3"   "BEGIN"    "红外检测到物体活动"
			fi	
		else
			if [ $(cat infared1_begin) -eq 1 ];then
			   echo  "0"   >   infared1_begin
			   add_warning   "$(cat infared1_serial)"    "$infared1_Id"    "$FsuId_All"      "$infared1DeviceId"    "$time"   "3"   "END"    "红外检测到物体活动"
			fi
		fi

		if [ $(echo "$(cat infared1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  infared1_alarm_count   #########重新计数
			date +%s  >  infared1_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat infared1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  infared1_close
			date +%s  >  infared1_open_time       #########记录开始告警时间
			add_warning   "$(cat infared1_serial_high_frequency)"    "$infared1_Id"    "$FsuId_All"     "$infared1DeviceId"     "$time"   "3"   "END"    "高频告警：红外检测到物体活动"
		fi
	fi
}

infared2_Id="0418003001"
infared2DeviceId="42020141800003"
#######红外告警
function infared2_warn()
{
  	##################记录告警次数######################
	if [ ! -f "infared2_alarm_count" ];then
			echo  "0"   >   infared2_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "infared2_open_time" ];then
			date +%s   >   infared2_open_time
	fi
	
	if [ "$(cat infared2_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################红外检测到物体活动########################
		if [ $(cat infared2) -eq 1 ];then
			echo  "1"   >   infared2_begin
			echo $((1+$(cat infared2_alarm_count))) >  infared2_alarm_count
			if [ $(cat infared2_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  infared2_serial_high_frequency
				insert_history   "$time"   "$infared2_Id"      "$(cat infared2)"   "$infared2DeviceId"    "红外2检测到物体活动"      "2"    "3"
				add_warning   "$(cat infared2_serial_high_frequency)"    "$infared2_Id"    "$FsuId_All"     "$infared2DeviceId"     "$time"   "3"   "BEGIN"    "高频告警：红外检测到物体活动"
				echo "0"  >  infared2_alarm_count   #########重新计数
				echo "1"  >  infared2_close    ##########关闭告警
				date +%s  >  infared2_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  infared2_serial
				insert_history   "$time"   "$infared2_Id"      "$(cat infared2)"   "$infared2DeviceId"    "红外2检测到物体活动"      "2"    "3"
				add_warning   "$(cat infared2_serial)"    "$infared2_Id"    "$FsuId_All"      "$infared2DeviceId"    "$time"   "3"   "BEGIN"    "红外检测到物体活动"
			fi	
		else
			if [ $(cat infared2_begin) -eq 1 ];then
			   echo  "0"   >   infared2_begin
			   add_warning   "$(cat infared2_serial)"    "$infared2_Id"    "$FsuId_All"      "$infared2DeviceId"    "$time"   "3"   "END"    "红外检测到物体活动"
			fi
		fi

		if [ $(echo "$(cat infared2_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  infared2_alarm_count   #########重新计数
			date +%s  >  infared2_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat infared2_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  infared2_close
			date +%s  >  infared2_open_time       #########记录开始告警时间
			add_warning   "$(cat infared2_serial_high_frequency)"    "$infared2_Id"    "$FsuId_All"     "$infared2DeviceId"     "$time"   "3"   "END"    "高频告警：红外检测到物体活动"
		fi
	fi
}


#######烟感告警
io_smoke1_Id="0418002001"
io_smoke1_deviceid="42020141800003"

function io_smoke1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "io_smoke1_alarm_count" ];then
			echo  "0"   >   io_smoke1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "io_smoke1_open_time" ];then
			date +%s   >   io_smoke1_open_time
	fi
	
	if [ "$(cat io_smoke1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################烟感检测到烟########################
		if [ $(cat io_smoke1) -eq 1 ];then
			echo  "1"   >   io_smoke1_begin
			echo $((1+$(cat io_smoke1_alarm_count))) >  io_smoke1_alarm_count
			if [ $(cat io_smoke1_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke1_serial_high_frequency
				insert_history   "$time"   "$io_smoke1_Id"      "$(cat io_smoke1)"   "$io_smoke1_deviceid"    "烟感1检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke1_serial_high_frequency)"    "$io_smoke1_Id"       "$FsuId_All"     "$io_smoke1_deviceid"     "$time"   "1"   "BEGIN"    "高频告警：烟感检测到烟"
				echo "0"  >  io_smoke1_alarm_count   #########重新计数
				echo "1"  >  io_smoke1_close    ##########关闭告警
				date +%s  >  io_smoke1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke1_serial
				insert_history   "$time"   "$io_smoke1_Id"      "$(cat io_smoke1)"   "$io_smoke1_deviceid"    "烟感1检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke1_serial)"    "$io_smoke1_Id"       "$FsuId_All"     "$io_smoke1_deviceid"     "$time"   "1"   "BEGIN"    "烟感检测到烟"
			fi	
		else
			if [ $(cat io_smoke1_begin) -eq 1 ];then
			   echo  "0"   >   io_smoke1_begin
			   add_warning   "$(cat io_smoke1_serial)"    "$io_smoke1_Id"       "$FsuId_All"     "$io_smoke1_deviceid"     "$time"   "1"   "END"    "烟感检测到烟"
			fi
		fi

		if [ $(echo "$(cat io_smoke1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke1_alarm_count   #########重新计数
			date +%s  >  io_smoke1_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat io_smoke1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke1_close
			date +%s  >  io_smoke1_open_time       #########记录开始告警时间
			add_warning   "$(cat io_smoke1_serial_high_frequency)"    "$io_smoke1_Id"       "$FsuId_All"     "$io_smoke1_deviceid"     "$time"   "1"   "END"    "高频告警：烟感检测到烟"
		fi
	fi
}

#######烟感告警
io_smoke2_Id="0418002001"
io_smoke2_deviceid="42020141800004"

function io_smoke2_warn()
{
  	##################记录告警次数######################
	if [ ! -f "io_smoke2_alarm_count" ];then
			echo  "0"   >   io_smoke2_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "io_smoke2_open_time" ];then
			date +%s   >   io_smoke2_open_time
	fi
	
	if [ "$(cat io_smoke2_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################烟感检测到烟########################
		if [ $(cat io_smoke2) -eq 1 ];then
			echo  "1"   >   io_smoke2_begin
			echo $((1+$(cat io_smoke2_alarm_count))) >  io_smoke2_alarm_count
			if [ $(cat io_smoke2_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke2_serial_high_frequency
				insert_history   "$time"   "$io_smoke2_Id"      "$(cat io_smoke2)"   "$io_smoke2_deviceid"    "烟感2检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke2_serial_high_frequency)"    "$io_smoke2_Id"       "$FsuId_All"     "$io_smoke2_deviceid"     "$time"   "1"   "BEGIN"    "高频告警：烟感检测到烟"
				echo "0"  >  io_smoke2_alarm_count   #########重新计数
				echo "1"  >  io_smoke2_close    ##########关闭告警
				date +%s  >  io_smoke2_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke2_serial
				insert_history   "$time"   "$io_smoke2_Id"      "$(cat io_smoke2)"   "$io_smoke2_deviceid"    "烟感2检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke2_serial)"    "$io_smoke2_Id"       "$FsuId_All"     "$io_smoke2_deviceid"     "$time"   "1"   "BEGIN"    "烟感检测到烟"
			fi	
		else
			if [ $(cat io_smoke2_begin) -eq 1 ];then
			   echo  "0"   >   io_smoke2_begin
			   add_warning   "$(cat io_smoke2_serial)"    "$io_smoke2_Id"       "$FsuId_All"     "$io_smoke2_deviceid"     "$time"   "1"   "END"    "烟感检测到烟"
			fi
		fi

		if [ $(echo "$(cat io_smoke2_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke2_alarm_count   #########重新计数
			date +%s  >  io_smoke2_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat io_smoke2_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke2_close
			date +%s  >  io_smoke2_open_time       #########记录开始告警时间
			add_warning   "$(cat io_smoke2_serial_high_frequency)"    "$io_smoke2_Id"       "$FsuId_All"     "$io_smoke2_deviceid"     "$time"   "1"   "END"    "高频告警：烟感检测到烟"
		fi
	fi
}

#######烟感告警
io_smoke3_Id="0418002001"
io_smoke3_deviceid="42020141800005"

function io_smoke3_warn()
{
  	##################记录告警次数######################
	if [ ! -f "io_smoke3_alarm_count" ];then
			echo  "0"   >   io_smoke3_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "io_smoke3_open_time" ];then
			date +%s   >   io_smoke3_open_time
	fi
	
	if [ "$(cat io_smoke3_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################烟感检测到烟########################
		if [ $(cat io_smoke3) -eq 1 ];then
			echo  "1"   >   io_smoke3_begin
			echo $((1+$(cat io_smoke3_alarm_count))) >  io_smoke3_alarm_count
			if [ $(cat io_smoke3_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke3_serial_high_frequency
				insert_history   "$time"   "$io_smoke3_Id"      "$(cat io_smoke3)"   "$io_smoke3_deviceid"    "烟感3检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke3_serial_high_frequency)"    "$io_smoke3_Id"       "$FsuId_All"     "$io_smoke3_deviceid"     "$time"   "1"   "BEGIN"    "高频告警：烟感检测到烟"
				echo "0"  >  io_smoke3_alarm_count   #########重新计数
				echo "1"  >  io_smoke3_close    ##########关闭告警
				date +%s  >  io_smoke3_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke3_serial
				insert_history   "$time"   "$io_smoke3_Id"      "$(cat io_smoke3)"   "$io_smoke3_deviceid"    "烟感3检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke3_serial)"    "$io_smoke3_Id"       "$FsuId_All"     "$io_smoke3_deviceid"     "$time"   "1"   "BEGIN"    "烟感检测到烟"
			fi	
		else
			if [ $(cat io_smoke3_begin) -eq 1 ];then
			   echo  "0"   >   io_smoke3_begin
			   add_warning   "$(cat io_smoke3_serial)"    "$io_smoke3_Id"       "$FsuId_All"     "$io_smoke3_deviceid"     "$time"   "1"   "END"    "烟感检测到烟"
			fi
		fi

		if [ $(echo "$(cat io_smoke3_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke3_alarm_count   #########重新计数
			date +%s  >  io_smoke3_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat io_smoke3_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke3_close
			date +%s  >  io_smoke3_open_time       #########记录开始告警时间
			add_warning   "$(cat io_smoke3_serial_high_frequency)"    "$io_smoke3_Id"       "$FsuId_All"     "$io_smoke3_deviceid"     "$time"   "1"   "END"    "高频告警：烟感检测到烟"
		fi
	fi
}

#######烟感告警
io_smoke4_Id="0418002001"
io_smoke4_deviceid="42020141800006"

function io_smoke4_warn()
{
  	##################记录告警次数######################
	if [ ! -f "io_smoke4_alarm_count" ];then
			echo  "0"   >   io_smoke4_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "io_smoke4_open_time" ];then
			date +%s   >   io_smoke4_open_time
	fi
	
	if [ "$(cat io_smoke4_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################烟感检测到烟########################
		if [ $(cat io_smoke4) -eq 1 ];then
			echo  "1"   >   io_smoke4_begin
			echo $((1+$(cat io_smoke4_alarm_count))) >  io_smoke4_alarm_count
			if [ $(cat io_smoke4_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke4_serial_high_frequency
				insert_history   "$time"   "$io_smoke4_Id"      "$(cat io_smoke4)"   "$io_smoke4_deviceid"    "烟感4检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke4_serial_high_frequency)"    "$io_smoke4_Id"       "$FsuId_All"     "$io_smoke4_deviceid"     "$time"   "1"   "BEGIN"    "高频告警：烟感检测到烟"
				echo "0"  >  io_smoke4_alarm_count   #########重新计数
				echo "1"  >  io_smoke4_close    ##########关闭告警
				date +%s  >  io_smoke4_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  io_smoke4_serial
				insert_history   "$time"   "$io_smoke4_Id"      "$(cat io_smoke4)"   "$io_smoke4_deviceid"    "烟感4检测到烟"      "1"    "1"
				add_warning   "$(cat io_smoke4_serial)"    "$io_smoke4_Id"       "$FsuId_All"     "$io_smoke4_deviceid"     "$time"   "1"   "BEGIN"    "烟感检测到烟"
			fi	
		else
			if [ $(cat io_smoke4_begin) -eq 1 ];then
			   echo  "0"   >   io_smoke4_begin
			   add_warning   "$(cat io_smoke4_serial)"    "$io_smoke4_Id"       "$FsuId_All"     "$io_smoke4_deviceid"     "$time"   "1"   "END"    "烟感检测到烟"
			fi
		fi

		if [ $(echo "$(cat io_smoke4_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke4_alarm_count   #########重新计数
			date +%s  >  io_smoke4_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat io_smoke4_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  io_smoke4_close
			date +%s  >  io_smoke4_open_time       #########记录开始告警时间
			add_warning   "$(cat io_smoke4_serial_high_frequency)"    "$io_smoke4_Id"       "$FsuId_All"     "$io_smoke4_deviceid"     "$time"   "1"   "END"    "高频告警：烟感检测到烟"
		fi
	fi
}


#######水浸告警
soak_resist1_Id="0418001001"
soak_resist1_deviceid="42020141800001"
function soak_resist1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "soak_resist1_alarm_count" ];then
			echo  "0"   >   soak_resist1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "soak_resist1_open_time" ];then
			date +%s   >   soak_resist1_open_time
	fi
	
	if [ "$(cat soak_resist1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat soak_resist1) -eq 1 ];then
			echo  "1"   >   soak_resist1_begin
			echo $((1+$(cat soak_resist1_alarm_count))) >  soak_resist1_alarm_count
			if [ $(cat soak_resist1_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist1_serial_high_frequency
				insert_history   "$time"   "$soak_resist1_Id"      "$(cat soak_resist1)"   "$soak_resist1_deviceid"    "水浸1检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist1_serial_high_frequency)"    "$soak_resist1_Id"       "$FsuId_All"     "$soak_resist1_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：水浸检测到水淹"
				echo "0"  >  soak_resist1_alarm_count   #########重新计数
				echo "1"  >  soak_resist1_close    ##########关闭告警
				date +%s  >  soak_resist1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist1_serial
				insert_history   "$time"   "$soak_resist1_Id"      "$(cat soak_resist1)"   "$soak_resist1_deviceid"    "水浸1检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist1_serial)"    "$soak_resist1_Id"       "$FsuId_All"     "$soak_resist1_deviceid"     "$time"   "2"   "BEGIN"    "水浸检测到水淹"
			fi	
		else
			if [ $(cat soak_resist1_begin) -eq 1 ];then
			   echo  "0"   >   soak_resist1_begin
			   add_warning   "$(cat soak_resist1_serial)"    "$soak_resist1_Id"       "$FsuId_All"     "$soak_resist1_deviceid"     "$time"   "2"   "END"    "水浸检测到水淹"
			fi
		fi

		if [ $(echo "$(cat soak_resist1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist1_alarm_count   #########重新计数
			date +%s  >  soak_resist1_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat soak_resist1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist1_close
			date +%s  >  soak_resist1_open_time       #########记录开始告警时间
			add_warning   "$(cat soak_resist1_serial_high_frequency)"    "$soak_resist1_Id"       "$FsuId_All"     "$soak_resist1_deviceid"     "$time"   "2"   "END"    "高频告警：水浸检测到水淹"
		fi
	fi
}

#######水浸告警
soak_resist2_Id="0418001001"
soak_resist2_deviceid="42020141800003"
function soak_resist2_warn()
{
  	##################记录告警次数######################
	if [ ! -f "soak_resist2_alarm_count" ];then
			echo  "0"   >   soak_resist2_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "soak_resist2_open_time" ];then
			date +%s   >   soak_resist2_open_time
	fi
	
	if [ "$(cat soak_resist2_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat soak_resist2) -eq 1 ];then
			echo  "1"   >   soak_resist2_begin
			echo $((1+$(cat soak_resist2_alarm_count))) >  soak_resist2_alarm_count
			if [ $(cat soak_resist2_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist2_serial_high_frequency
				insert_history   "$time"   "$soak_resist2_Id"      "$(cat soak_resist2)"   "$soak_resist2_deviceid"    "水浸2检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist2_serial_high_frequency)"    "$soak_resist2_Id"       "$FsuId_All"     "$soak_resist2_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：水浸检测到水淹"
				echo "0"  >  soak_resist2_alarm_count   #########重新计数
				echo "1"  >  soak_resist2_close    ##########关闭告警
				date +%s  >  soak_resist2_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist2_serial
				insert_history   "$time"   "$soak_resist2_Id"      "$(cat soak_resist2)"   "$soak_resist2_deviceid"    "水浸2检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist2_serial)"    "$soak_resist2_Id"       "$FsuId_All"     "$soak_resist2_deviceid"     "$time"   "2"   "BEGIN"    "水浸检测到水淹"
			fi	
		else
			if [ $(cat soak_resist2_begin) -eq 1 ];then
			   echo  "0"   >   soak_resist2_begin
			   add_warning   "$(cat soak_resist2_serial)"    "$soak_resist2_Id"       "$FsuId_All"     "$soak_resist2_deviceid"     "$time"   "2"   "END"    "水浸检测到水淹"
			fi
		fi

		if [ $(echo "$(cat soak_resist2_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist2_alarm_count   #########重新计数
			date +%s  >  soak_resist2_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat soak_resist2_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist2_close
			date +%s  >  soak_resist2_open_time       #########记录开始告警时间
			add_warning   "$(cat soak_resist2_serial_high_frequency)"    "$soak_resist2_Id"       "$FsuId_All"     "$soak_resist2_deviceid"     "$time"   "2"   "END"    "高频告警：水浸检测到水淹"
		fi
	fi
}

#######水浸告警
soak_resist3_Id="0418001001"
soak_resist3_deviceid="42020141800004"
function soak_resist3_warn()
{
  	##################记录告警次数######################
	if [ ! -f "soak_resist3_alarm_count" ];then
			echo  "0"   >   soak_resist3_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "soak_resist3_open_time" ];then
			date +%s   >   soak_resist3_open_time
	fi
	
	if [ "$(cat soak_resist3_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat soak_resist3) -eq 1 ];then
			echo  "1"   >   soak_resist3_begin
			echo $((1+$(cat soak_resist3_alarm_count))) >  soak_resist3_alarm_count
			if [ $(cat soak_resist3_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist3_serial_high_frequency
				insert_history   "$time"   "$soak_resist3_Id"      "$(cat soak_resist3)"   "$soak_resist3_deviceid"    "水浸3检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist3_serial_high_frequency)"    "$soak_resist3_Id"       "$FsuId_All"     "$soak_resist3_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：水浸检测到水淹"
				echo "0"  >  soak_resist3_alarm_count   #########重新计数
				echo "1"  >  soak_resist3_close    ##########关闭告警
				date +%s  >  soak_resist3_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist3_serial
				insert_history   "$time"   "$soak_resist3_Id"      "$(cat soak_resist3)"   "$soak_resist3_deviceid"    "水浸3检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist3_serial)"    "$soak_resist3_Id"       "$FsuId_All"     "$soak_resist3_deviceid"     "$time"   "2"   "BEGIN"    "水浸检测到水淹"
			fi	
		else
			if [ $(cat soak_resist3_begin) -eq 1 ];then
			   echo  "0"   >   soak_resist3_begin
			   add_warning   "$(cat soak_resist3_serial)"    "$soak_resist3_Id"       "$FsuId_All"     "$soak_resist3_deviceid"     "$time"   "2"   "END"    "水浸检测到水淹"
			fi
		fi

		if [ $(echo "$(cat soak_resist3_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist3_alarm_count   #########重新计数
			date +%s  >  soak_resist3_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat soak_resist3_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist3_close
			date +%s  >  soak_resist3_open_time       #########记录开始告警时间
			add_warning   "$(cat soak_resist3_serial_high_frequency)"    "$soak_resist3_Id"       "$FsuId_All"     "$soak_resist3_deviceid"     "$time"   "2"   "END"    "高频告警：水浸检测到水淹"
		fi
	fi
}

#######水浸告警
soak_resist4_Id="0418001001"
soak_resist4_deviceid="42020141800005"
function soak_resist4_warn()
{
  	##################记录告警次数######################
	if [ ! -f "soak_resist4_alarm_count" ];then
			echo  "0"   >   soak_resist4_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "soak_resist4_open_time" ];then
			date +%s   >   soak_resist4_open_time
	fi
	
	if [ "$(cat soak_resist4_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat soak_resist4) -eq 1 ];then
			echo  "1"   >   soak_resist4_begin
			echo $((1+$(cat soak_resist4_alarm_count))) >  soak_resist4_alarm_count
			if [ $(cat soak_resist4_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist4_serial_high_frequency
				insert_history   "$time"   "$soak_resist4_Id"      "$(cat soak_resist4)"   "$soak_resist4_deviceid"    "水浸4检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist4_serial_high_frequency)"    "$soak_resist4_Id"       "$FsuId_All"     "$soak_resist4_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：水浸检测到水淹"
				echo "0"  >  soak_resist4_alarm_count   #########重新计数
				echo "1"  >  soak_resist4_close    ##########关闭告警
				date +%s  >  soak_resist4_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  soak_resist4_serial
				insert_history   "$time"   "$soak_resist4_Id"      "$(cat soak_resist4)"   "$soak_resist4_deviceid"    "水浸4检测到水淹"      "2"    "2"
				add_warning   "$(cat soak_resist4_serial)"    "$soak_resist4_Id"       "$FsuId_All"     "$soak_resist4_deviceid"     "$time"   "2"   "BEGIN"    "水浸检测到水淹"
			fi	
		else
			if [ $(cat soak_resist4_begin) -eq 1 ];then
			   echo  "0"   >   soak_resist4_begin
			   add_warning   "$(cat soak_resist4_serial)"    "$soak_resist4_Id"       "$FsuId_All"     "$soak_resist4_deviceid"     "$time"   "2"   "END"    "水浸检测到水淹"
			fi
		fi

		if [ $(echo "$(cat soak_resist4_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist4_alarm_count   #########重新计数
			date +%s  >  soak_resist4_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat soak_resist4_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  soak_resist4_close
			date +%s  >  soak_resist4_open_time       #########记录开始告警时间
			add_warning   "$(cat soak_resist4_serial_high_frequency)"    "$soak_resist4_Id"       "$FsuId_All"     "$soak_resist4_deviceid"     "$time"   "2"   "END"    "高频告警：水浸检测到水淹"
		fi
	fi
}


#######温度1过高告警
temperature1_too_high_Id="0418004001"
temperature1_too_high_deviceid="42020141800003"
function temperature1_too_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature1_too_high_alarm_count" ];then
			echo  "0"   >   temperature1_too_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature1_too_high_open_time" ];then
			date +%s   >   temperature1_too_high_open_time
	fi
	
	if [ "$(cat temperature1_too_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature1_too_high) -eq 1 ];then
			echo  "1"   >   temperature1_too_high_begin
			echo $((1+$(cat temperature1_too_high_alarm_count))) >  temperature1_too_high_alarm_count
			if [ $(cat temperature1_too_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_too_high_serial_high_frequency
				insert_history   "$time"   "$temperature1_too_high_Id"      "$(cat temperature1_too_high)"   "$temperature1_too_high_deviceid"    "温度1过高告警"      "2"    "2"
				add_warning   "$(cat temperature1_too_high_serial_high_frequency)"    "$temperature1_too_high_Id"       "$FsuId_All"     "$temperature1_too_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度1过高告警"
				echo "0"  >  temperature1_too_high_alarm_count   #########重新计数
				echo "1"  >  temperature1_too_high_close    ##########关闭告警
				date +%s  >  temperature1_too_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_too_high_serial
				insert_history   "$time"   "$temperature1_too_high_Id"      "$(cat temperature1_too_high)"   "$temperature1_too_high_deviceid"    "温度1过高告警"      "2"    "2"
				add_warning   "$(cat temperature1_too_high_serial)"    "$temperature1_too_high_Id"       "$FsuId_All"     "$temperature1_too_high_deviceid"     "$time"   "2"   "BEGIN"    "温度1过高告警"
			fi	
		else
			if [ $(cat temperature1_too_high_begin) -eq 1 ];then
			   echo  "0"   >   temperature1_too_high_begin
			   add_warning   "$(cat temperature1_too_high_serial)"    "$temperature1_too_high_Id"       "$FsuId_All"     "$temperature1_too_high_deviceid"     "$time"   "2"   "END"    "温度1过高告警"
			fi
		fi

		if [ $(echo "$(cat temperature1_too_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_too_high_alarm_count   #########重新计数
			date +%s  >  temperature1_too_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature1_too_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_too_high_close
			date +%s  >  temperature1_too_high_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature1_too_high_serial_high_frequency)"    "$temperature1_too_high_Id"       "$FsuId_All"     "$temperature1_too_high_deviceid"     "$time"   "2"   "END"    "高频告警：温度1过高告警"
		fi
	fi
}

#######温度2过高告警
temperature2_too_high_Id="0418004001"
temperature2_too_high_deviceid="42020141800004"
function temperature2_too_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature2_too_high_alarm_count" ];then
			echo  "0"   >   temperature2_too_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature2_too_high_open_time" ];then
			date +%s   >   temperature2_too_high_open_time
	fi
	
	if [ "$(cat temperature2_too_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature2_too_high) -eq 1 ];then
			echo  "1"   >   temperature2_too_high_begin
			echo $((1+$(cat temperature2_too_high_alarm_count))) >  temperature2_too_high_alarm_count
			if [ $(cat temperature2_too_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_too_high_serial_high_frequency
				insert_history   "$time"   "$temperature2_too_high_Id"      "$(cat temperature2_too_high)"   "$temperature2_too_high_deviceid"    "温度2过高告警"      "2"    "2"
				add_warning   "$(cat temperature2_too_high_serial_high_frequency)"    "$temperature2_too_high_Id"       "$FsuId_All"     "$temperature2_too_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度2过高告警"
				echo "0"  >  temperature2_too_high_alarm_count   #########重新计数
				echo "1"  >  temperature2_too_high_close    ##########关闭告警
				date +%s  >  temperature2_too_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_too_high_serial
				insert_history   "$time"   "$temperature2_too_high_Id"      "$(cat temperature2_too_high)"   "$temperature2_too_high_deviceid"    "温度2过高告警"      "2"    "2"
				add_warning   "$(cat temperature2_too_high_serial)"    "$temperature2_too_high_Id"       "$FsuId_All"     "$temperature2_too_high_deviceid"     "$time"   "2"   "BEGIN"    "温度2过高告警"
			fi	
		else
			if [ $(cat temperature2_too_high_begin) -eq 1 ];then
			   echo  "0"   >   temperature2_too_high_begin
			   add_warning   "$(cat temperature2_too_high_serial)"    "$temperature2_too_high_Id"       "$FsuId_All"     "$temperature2_too_high_deviceid"     "$time"   "2"   "END"    "温度2过高告警"
			fi
		fi

		if [ $(echo "$(cat temperature2_too_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_too_high_alarm_count   #########重新计数
			date +%s  >  temperature2_too_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature2_too_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_too_high_close
			date +%s  >  temperature2_too_high_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature2_too_high_serial_high_frequency)"    "$temperature2_too_high_Id"       "$FsuId_All"     "$temperature2_too_high_deviceid"     "$time"   "2"   "END"    "高频告警：温度2过高告警"
		fi
	fi
}

#######温度1超高告警
temperature1_super_high_Id="0418005001"
temperature1_super_high_deviceid="42020141800003"
function temperature1_super_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature1_super_high_alarm_count" ];then
			echo  "0"   >   temperature1_super_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature1_super_high_open_time" ];then
			date +%s   >   temperature1_super_high_open_time
	fi
	
	if [ "$(cat temperature1_super_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature1_super_high) -eq 1 ];then
			echo  "1"   >   temperature1_super_high_begin
			echo $((1+$(cat temperature1_super_high_alarm_count))) >  temperature1_super_high_alarm_count
			if [ $(cat temperature1_super_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_super_high_serial_high_frequency
				insert_history   "$time"   "$temperature1_super_high_Id"      "$(cat temperature1_super_high)"   "$temperature1_super_high_deviceid"    "温度1超高告警"      "2"    "2"
				add_warning   "$(cat temperature1_super_high_serial_high_frequency)"    "$temperature1_super_high_Id"       "$FsuId_All"     "$temperature1_super_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度1超高告警"
				echo "0"  >  temperature1_super_high_alarm_count   #########重新计数
				echo "1"  >  temperature1_super_high_close    ##########关闭告警
				date +%s  >  temperature1_super_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_super_high_serial
				insert_history   "$time"   "$temperature1_super_high_Id"      "$(cat temperature1_super_high)"   "$temperature1_super_high_deviceid"    "温度1超高告警"      "2"    "2"
				add_warning   "$(cat temperature1_super_high_serial)"    "$temperature1_super_high_Id"       "$FsuId_All"     "$temperature1_super_high_deviceid"     "$time"   "2"   "BEGIN"    "温度1超高告警"
			fi	
		else
			if [ $(cat temperature1_super_high_begin) -eq 1 ];then
			   echo  "0"   >   temperature1_super_high_begin
			   add_warning   "$(cat temperature1_super_high_serial)"    "$temperature1_super_high_Id"       "$FsuId_All"     "$temperature1_super_high_deviceid"     "$time"   "2"   "END"    "温度1超高告警"
			fi
		fi

		if [ $(echo "$(cat temperature1_super_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_super_high_alarm_count   #########重新计数
			date +%s  >  temperature1_super_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature1_super_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_super_high_close
			date +%s  >  temperature1_super_high_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature1_super_high_serial_high_frequency)"    "$temperature1_super_high_Id"       "$FsuId_All"     "$temperature1_super_high_deviceid"     "$time"   "2"   "END"    "高频告警：温度1超高告警"
		fi
	fi
}

#######温度2超高告警
temperature2_super_high_Id="0418005001"
temperature2_super_high_deviceid="42020141800004"
function temperature2_super_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature2_super_high_alarm_count" ];then
			echo  "0"   >   temperature2_super_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature2_super_high_open_time" ];then
			date +%s   >   temperature2_super_high_open_time
	fi
	
	if [ "$(cat temperature2_super_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature2_super_high) -eq 1 ];then
			echo  "1"   >   temperature2_super_high_begin
			echo $((1+$(cat temperature2_super_high_alarm_count))) >  temperature2_super_high_alarm_count
			if [ $(cat temperature2_super_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_super_high_serial_high_frequency
				insert_history   "$time"   "$temperature2_super_high_Id"      "$(cat temperature2_super_high)"   "$temperature2_super_high_deviceid"    "温度2超高告警"      "2"    "2"
				add_warning   "$(cat temperature2_super_high_serial_high_frequency)"    "$temperature2_super_high_Id"       "$FsuId_All"     "$temperature2_super_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度2超高告警"
				echo "0"  >  temperature2_super_high_alarm_count   #########重新计数
				echo "1"  >  temperature2_super_high_close    ##########关闭告警
				date +%s  >  temperature2_super_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_super_high_serial
				insert_history   "$time"   "$temperature2_super_high_Id"      "$(cat temperature2_super_high)"   "$temperature2_super_high_deviceid"    "温度2超高告警"      "2"    "2"
				add_warning   "$(cat temperature2_super_high_serial)"    "$temperature2_super_high_Id"       "$FsuId_All"     "$temperature2_super_high_deviceid"     "$time"   "2"   "BEGIN"    "温度2超高告警"
			fi	
		else
			if [ $(cat temperature2_super_high_begin) -eq 1 ];then
			   echo  "0"   >   temperature2_super_high_begin
			   add_warning   "$(cat temperature2_super_high_serial)"    "$temperature2_super_high_Id"       "$FsuId_All"     "$temperature2_super_high_deviceid"     "$time"   "2"   "END"    "温度2超高告警"
			fi
		fi

		if [ $(echo "$(cat temperature2_super_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_super_high_alarm_count   #########重新计数
			date +%s  >  temperature2_super_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature2_super_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_super_high_close
			date +%s  >  temperature2_super_high_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature2_super_high_serial_high_frequency)"    "$temperature2_super_high_Id"       "$FsuId_All"     "$temperature2_super_high_deviceid"     "$time"   "2"   "END"    "高频告警：温度2超高告警"
		fi
	fi
}

#######温度1过低告警
temperature1_too_low_Id="0418006001"
temperature1_too_low_deviceid="42020141800003"
function temperature1_too_low_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature1_too_low_alarm_count" ];then
			echo  "0"   >   temperature1_too_low_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature1_too_low_open_time" ];then
			date +%s   >   temperature1_too_low_open_time
	fi
	
	if [ "$(cat temperature1_too_low_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature1_too_low) -eq 1 ];then
			echo  "1"   >   temperature1_too_low_begin
			echo $((1+$(cat temperature1_too_low_alarm_count))) >  temperature1_too_low_alarm_count
			if [ $(cat temperature1_too_low_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_too_low_serial_high_frequency
				insert_history   "$time"   "$temperature1_too_low_Id"      "$(cat temperature1_too_low)"   "$temperature1_too_low_deviceid"    "温度1过低告警"      "2"    "2"
				add_warning   "$(cat temperature1_too_low_serial_high_frequency)"    "$temperature1_too_low_Id"       "$FsuId_All"     "$temperature1_too_low_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度1过低告警"
				echo "0"  >  temperature1_too_low_alarm_count   #########重新计数
				echo "1"  >  temperature1_too_low_close    ##########关闭告警
				date +%s  >  temperature1_too_low_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature1_too_low_serial
				insert_history   "$time"   "$temperature1_too_low_Id"      "$(cat temperature1_too_low)"   "$temperature1_too_low_deviceid"    "温度1过低告警"      "2"    "2"
				add_warning   "$(cat temperature1_too_low_serial)"    "$temperature1_too_low_Id"       "$FsuId_All"     "$temperature1_too_low_deviceid"     "$time"   "2"   "BEGIN"    "温度1过低告警"
			fi	
		else
			if [ $(cat temperature1_too_low_begin) -eq 1 ];then
			   echo  "0"   >   temperature1_too_low_begin
			   add_warning   "$(cat temperature1_too_low_serial)"    "$temperature1_too_low_Id"       "$FsuId_All"     "$temperature1_too_low_deviceid"     "$time"   "2"   "END"    "温度1过低告警"
			fi
		fi

		if [ $(echo "$(cat temperature1_too_low_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_too_low_alarm_count   #########重新计数
			date +%s  >  temperature1_too_low_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature1_too_low_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature1_too_low_close
			date +%s  >  temperature1_too_low_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature1_too_low_serial_high_frequency)"    "$temperature1_too_low_Id"       "$FsuId_All"     "$temperature1_too_low_deviceid"     "$time"   "2"   "END"    "高频告警：温度1过低告警"
		fi
	fi
}

#######温度2过低告警
temperature2_too_low_Id="0418006001"
temperature2_too_low_deviceid="42020141800004"
function temperature2_too_low_warn()
{
  	##################记录告警次数######################
	if [ ! -f "temperature2_too_low_alarm_count" ];then
			echo  "0"   >   temperature2_too_low_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "temperature2_too_low_open_time" ];then
			date +%s   >   temperature2_too_low_open_time
	fi
	
	if [ "$(cat temperature2_too_low_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat temperature2_too_low) -eq 1 ];then
			echo  "1"   >   temperature2_too_low_begin
			echo $((1+$(cat temperature2_too_low_alarm_count))) >  temperature2_too_low_alarm_count
			if [ $(cat temperature2_too_low_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_too_low_serial_high_frequency
				insert_history   "$time"   "$temperature2_too_low_Id"      "$(cat temperature2_too_low)"   "$temperature2_too_low_deviceid"    "温度2过低告警"      "2"    "2"
				add_warning   "$(cat temperature2_too_low_serial_high_frequency)"    "$temperature2_too_low_Id"       "$FsuId_All"     "$temperature2_too_low_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：温度2过低告警"
				echo "0"  >  temperature2_too_low_alarm_count   #########重新计数
				echo "1"  >  temperature2_too_low_close    ##########关闭告警
				date +%s  >  temperature2_too_low_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  temperature2_too_low_serial
				insert_history   "$time"   "$temperature2_too_low_Id"      "$(cat temperature2_too_low)"   "$temperature2_too_low_deviceid"    "温度2过低告警"      "2"    "2"
				add_warning   "$(cat temperature2_too_low_serial)"    "$temperature2_too_low_Id"       "$FsuId_All"     "$temperature2_too_low_deviceid"     "$time"   "2"   "BEGIN"    "温度2过低告警"
			fi	
		else
			if [ $(cat temperature2_too_low_begin) -eq 1 ];then
			   echo  "0"   >   temperature2_too_low_begin
			   add_warning   "$(cat temperature2_too_low_serial)"    "$temperature2_too_low_Id"       "$FsuId_All"     "$temperature2_too_low_deviceid"     "$time"   "2"   "END"    "温度2过低告警"
			fi
		fi

		if [ $(echo "$(cat temperature2_too_low_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_too_low_alarm_count   #########重新计数
			date +%s  >  temperature2_too_low_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat temperature2_too_low_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  temperature2_too_low_close
			date +%s  >  temperature2_too_low_open_time       #########记录开始告警时间
			add_warning   "$(cat temperature2_too_low_serial_high_frequency)"    "$temperature2_too_low_Id"       "$FsuId_All"     "$temperature2_too_low_deviceid"     "$time"   "2"   "END"    "高频告警：温度2过低告警"
		fi
	fi
}

#######湿度一过高告警
humidity1_too_high_Id="0418007001"
humidity1_too_high_deviceid="42020141800004"
function humidity1_too_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "humidity1_too_high_alarm_count" ];then
			echo  "0"   >   humidity1_too_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "humidity1_too_high_open_time" ];then
			date +%s   >   humidity1_too_high_open_time
	fi
	
	if [ "$(cat humidity1_too_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat humidity1_too_high) -eq 1 ];then
			echo  "1"   >   humidity1_too_high_begin
			echo $((1+$(cat humidity1_too_high_alarm_count))) >  humidity1_too_high_alarm_count
			if [ $(cat humidity1_too_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity1_too_high_serial_high_frequency
				insert_history   "$time"   "$humidity1_too_high_Id"      "$(cat humidity1_too_high)"   "$humidity1_too_high_deviceid"    "湿度一过低告警"      "2"    "2"
				add_warning   "$(cat humidity1_too_high_serial_high_frequency)"    "$humidity1_too_high_Id"       "$FsuId_All"     "$humidity1_too_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：湿度一过低告警"
				echo "0"  >  humidity1_too_high_alarm_count   #########重新计数
				echo "1"  >  humidity1_too_high_close    ##########关闭告警
				date +%s  >  humidity1_too_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity1_too_high_serial
				insert_history   "$time"   "$humidity1_too_high_Id"      "$(cat humidity1_too_high)"   "$humidity1_too_high_deviceid"    "湿度一过低告警"      "2"    "2"
				add_warning   "$(cat humidity1_too_high_serial)"    "$humidity1_too_high_Id"       "$FsuId_All"     "$humidity1_too_high_deviceid"     "$time"   "2"   "BEGIN"    "湿度一过低告警"
			fi	
		else
			if [ $(cat humidity1_too_high_begin) -eq 1 ];then
			   echo  "0"   >   humidity1_too_high_begin
			   add_warning   "$(cat humidity1_too_high_serial)"    "$humidity1_too_high_Id"       "$FsuId_All"     "$humidity1_too_high_deviceid"     "$time"   "2"   "END"    "湿度一过低告警"
			fi
		fi

		if [ $(echo "$(cat humidity1_too_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity1_too_high_alarm_count   #########重新计数
			date +%s  >  humidity1_too_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat humidity1_too_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity1_too_high_close
			date +%s  >  humidity1_too_high_open_time       #########记录开始告警时间
			add_warning   "$(cat humidity1_too_high_serial_high_frequency)"    "$humidity1_too_high_Id"       "$FsuId_All"     "$humidity1_too_high_deviceid"     "$time"   "2"   "END"    "高频告警：湿度一过低告警"
		fi
	fi
}

#######湿度一过低告警
humidity1_too_low_Id="0418008001"
humidity1_too_low_deviceid="42020141800003"
function humidity1_too_low_warn()
{
  	##################记录告警次数######################
	if [ ! -f "humidity1_too_low_alarm_count" ];then
			echo  "0"   >   humidity1_too_low_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "humidity1_too_low_open_time" ];then
			date +%s   >   humidity1_too_low_open_time
	fi
	
	if [ "$(cat humidity1_too_low_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat humidity1_too_low) -eq 1 ];then
			echo  "1"   >   humidity1_too_low_begin
			echo $((1+$(cat humidity1_too_low_alarm_count))) >  humidity1_too_low_alarm_count
			if [ $(cat humidity1_too_low_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity1_too_low_serial_high_frequency
				insert_history   "$time"   "$humidity1_too_low_Id"      "$(cat humidity1_too_low)"   "$humidity1_too_low_deviceid"    "湿度一过低告警"      "2"    "2"
				add_warning   "$(cat humidity1_too_low_serial_high_frequency)"    "$humidity1_too_low_Id"       "$FsuId_All"     "$humidity1_too_low_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：湿度一过低告警"
				echo "0"  >  humidity1_too_low_alarm_count   #########重新计数
				echo "1"  >  humidity1_too_low_close    ##########关闭告警
				date +%s  >  humidity1_too_low_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity1_too_low_serial
				insert_history   "$time"   "$humidity1_too_low_Id"      "$(cat humidity1_too_low)"   "$humidity1_too_low_deviceid"    "湿度一过低告警"      "2"    "2"
				add_warning   "$(cat humidity1_too_low_serial)"    "$humidity1_too_low_Id"       "$FsuId_All"     "$humidity1_too_low_deviceid"     "$time"   "2"   "BEGIN"    "湿度一过低告警"
			fi	
		else
			if [ $(cat humidity1_too_low_begin) -eq 1 ];then
			   echo  "0"   >   humidity1_too_low_begin
			   add_warning   "$(cat humidity1_too_low_serial)"    "$humidity1_too_low_Id"       "$FsuId_All"     "$humidity1_too_low_deviceid"     "$time"   "2"   "END"    "湿度一过低告警"
			fi
		fi

		if [ $(echo "$(cat humidity1_too_low_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity1_too_low_alarm_count   #########重新计数
			date +%s  >  humidity1_too_low_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat humidity1_too_low_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity1_too_low_close
			date +%s  >  humidity1_too_low_open_time       #########记录开始告警时间
			add_warning   "$(cat humidity1_too_low_serial_high_frequency)"    "$humidity1_too_low_Id"       "$FsuId_All"     "$humidity1_too_low_deviceid"     "$time"   "2"   "END"    "高频告警：湿度一过低告警"
		fi
	fi
}

#######湿度二过高告警
humidity2_too_high_Id="0418007001"
humidity2_too_high_deviceid="42020141800004"
function humidity2_too_high_warn()
{
  	##################记录告警次数######################
	if [ ! -f "humidity2_too_high_alarm_count" ];then
			echo  "0"   >   humidity2_too_high_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "humidity2_too_high_open_time" ];then
			date +%s   >   humidity2_too_high_open_time
	fi
	
	if [ "$(cat humidity2_too_high_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat humidity2_too_high) -eq 1 ];then
			echo  "1"   >   humidity2_too_high_begin
			echo $((1+$(cat humidity2_too_high_alarm_count))) >  humidity2_too_high_alarm_count
			if [ $(cat humidity2_too_high_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity2_too_high_serial_high_frequency
				insert_history   "$time"   "$humidity2_too_high_Id"      "$(cat humidity2_too_high)"   "$humidity2_too_high_deviceid"    "湿度二过低告警"      "2"    "2"
				add_warning   "$(cat humidity2_too_high_serial_high_frequency)"    "$humidity2_too_high_Id"       "$FsuId_All"     "$humidity2_too_high_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：湿度二过低告警"
				echo "0"  >  humidity2_too_high_alarm_count   #########重新计数
				echo "1"  >  humidity2_too_high_close    ##########关闭告警
				date +%s  >  humidity2_too_high_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity2_too_high_serial
				insert_history   "$time"   "$humidity2_too_high_Id"      "$(cat humidity2_too_high)"   "$humidity2_too_high_deviceid"    "湿度二过低告警"      "2"    "2"
				add_warning   "$(cat humidity2_too_high_serial)"    "$humidity2_too_high_Id"       "$FsuId_All"     "$humidity2_too_high_deviceid"     "$time"   "2"   "BEGIN"    "湿度二过低告警"
			fi	
		else
			if [ $(cat humidity2_too_high_begin) -eq 1 ];then
			   echo  "0"   >   humidity2_too_high_begin
			   add_warning   "$(cat humidity2_too_high_serial)"    "$humidity2_too_high_Id"       "$FsuId_All"     "$humidity2_too_high_deviceid"     "$time"   "2"   "END"    "湿度二过低告警"
			fi
		fi

		if [ $(echo "$(cat humidity2_too_high_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity2_too_high_alarm_count   #########重新计数
			date +%s  >  humidity2_too_high_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat humidity2_too_high_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity2_too_high_close
			date +%s  >  humidity2_too_high_open_time       #########记录开始告警时间
			add_warning   "$(cat humidity2_too_high_serial_high_frequency)"    "$humidity2_too_high_Id"       "$FsuId_All"     "$humidity2_too_high_deviceid"     "$time"   "2"   "END"    "高频告警：湿度二过低告警"
		fi
	fi
}

#######湿度二过低告警
humidity2_too_low_Id="0418008001"
humidity2_too_low_deviceid="42020141800004"
function humidity2_too_low_warn()
{
  	##################记录告警次数######################
	if [ ! -f "humidity2_too_low_alarm_count" ];then
			echo  "0"   >   humidity2_too_low_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "humidity2_too_low_open_time" ];then
			date +%s   >   humidity2_too_low_open_time
	fi
	
	if [ "$(cat humidity2_too_low_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################水浸检测到水淹########################
		if [ $(cat humidity2_too_low) -eq 1 ];then
			echo  "1"   >   humidity2_too_low_begin
			echo $((1+$(cat humidity2_too_low_alarm_count))) >  humidity2_too_low_alarm_count
			if [ $(cat humidity2_too_low_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity2_too_low_serial_high_frequency
				insert_history   "$time"   "$humidity2_too_low_Id"      "$(cat humidity2_too_low)"   "$humidity2_too_low_deviceid"    "湿度二过低告警"      "2"    "2"
				add_warning   "$(cat humidity2_too_low_serial_high_frequency)"    "$humidity2_too_low_Id"       "$FsuId_All"     "$humidity2_too_low_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：湿度二过低告警"
				echo "0"  >  humidity2_too_low_alarm_count   #########重新计数
				echo "1"  >  humidity2_too_low_close    ##########关闭告警
				date +%s  >  humidity2_too_low_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  humidity2_too_low_serial
				insert_history   "$time"   "$humidity2_too_low_Id"      "$(cat humidity2_too_low)"   "$humidity2_too_low_deviceid"    "湿度二过低告警"      "2"    "2"
				add_warning   "$(cat humidity2_too_low_serial)"    "$humidity2_too_low_Id"       "$FsuId_All"     "$humidity2_too_low_deviceid"     "$time"   "2"   "BEGIN"    "湿度二过低告警"
			fi	
		else
			if [ $(cat humidity2_too_low_begin) -eq 1 ];then
			   echo  "0"   >   humidity2_too_low_begin
			   add_warning   "$(cat humidity2_too_low_serial)"    "$humidity2_too_low_Id"       "$FsuId_All"     "$humidity2_too_low_deviceid"     "$time"   "2"   "END"    "湿度二过低告警"
			fi
		fi

		if [ $(echo "$(cat humidity2_too_low_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity2_too_low_alarm_count   #########重新计数
			date +%s  >  humidity2_too_low_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat humidity2_too_low_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  humidity2_too_low_close
			date +%s  >  humidity2_too_low_open_time       #########记录开始告警时间
			add_warning   "$(cat humidity2_too_low_serial_high_frequency)"    "$humidity2_too_low_Id"       "$FsuId_All"     "$humidity2_too_low_deviceid"     "$time"   "2"   "END"    "高频告警：湿度二过低告警"
		fi
	fi
}


no_electricity_Id="0416001001" 
no_electricity_deviceId="42020141600003"
#######智能电表停电告警
function no_electricity_warn()
{
  	##################记录告警次数######################
	if [ ! -f "no_electricity_alarm_count" ];then
			echo  "0"   >   no_electricity_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "no_electricity_open_time" ];then
			date +%s   >   no_electricity_open_time
	fi
	
	if [ "$(cat no_electricity_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################智能电表检测到停电########################
		if [ $(cat no_electricity) -eq 1 ];then
			echo  "1"   >   no_electricity_begin
			echo $((1+$(cat no_electricity_alarm_count))) >  no_electricity_alarm_count
			if [ $(cat no_electricity_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  no_electricity_serial_high_frequency
				insert_history   "$time"   "$no_electricity_Id"      "$(cat no_electricity)"   "$no_electricity_deviceId"    "智能电表检测到停电"      "2"    "3"
				add_warning   "$(cat no_electricity_serial_high_frequency)"    "$no_electricity_Id"       "$FsuId_All"     "$no_electricity_deviceId"     "$time"   "3"   "BEGIN"    "高频告警：智能电表检测到停电"
				echo "0"  >  no_electricity_alarm_count   #########重新计数
				echo "1"  >  no_electricity_close    ##########关闭告警
				date +%s  >  no_electricity_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  no_electricity_serial
				insert_history   "$time"   "$no_electricity_Id"      "$(cat no_electricity)"   "$no_electricity_deviceId"    "智能电表检测到停电"      "2"    "3"
				add_warning   "$(cat no_electricity_serial)"    "$no_electricity_Id"       "$FsuId_All"     "$no_electricity_deviceId"     "$time"   "3"   "BEGIN"    "智能电表检测到停电"
			fi	
		else
			if [ $(cat no_electricity_begin) -eq 1 ];then
			   echo  "0"   >   no_electricity_begin
			   add_warning   "$(cat no_electricity_serial)"    "$no_electricity_Id"       "$FsuId_All"     "$no_electricity_deviceId"     "$time"   "3"   "END"    "智能电表检测到停电"
			fi
		fi

		if [ $(echo "$(cat no_electricity_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  no_electricity_alarm_count   #########重新计数
			date +%s  >  no_electricity_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat no_electricity_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  no_electricity_close
			date +%s  >  no_electricity_open_time       #########记录开始告警时间
			add_warning   "$(cat no_electricity_serial_high_frequency)"    "$no_electricity_Id"       "$FsuId_All"     "$no_electricity_deviceId"     "$time"   "3"   "END"    "高频告警：智能电表检测到停电"
		fi
	fi
}


voltage_unbalance1_deviceid="42020140700004"
voltage_unbalance1_Id="0407005001"
#######蓄电池组1中间点电压不平衡
function voltage_unbalance1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "voltage_unbalance1_alarm_count" ];then
			echo  "0"   >   voltage_unbalance1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "voltage_unbalance1_open_time" ];then
			date +%s   >   voltage_unbalance1_open_time
	fi
	
	if [ "$(cat voltage_unbalance1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################蓄电池组1中间点电压不平衡########################
		if [ $(cat voltage_unbalance1) -eq 1 ];then
			echo  "1"   >   voltage_unbalance1_begin
			echo $((1+$(cat voltage_unbalance1_alarm_count))) >  voltage_unbalance1_alarm_count
			if [ $(cat voltage_unbalance1_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  voltage_unbalance1_serial_high_frequency
				insert_history   "$time"   "$voltage_unbalance1_Id"      "$(cat voltage_unbalance1)"   "$voltage_unbalance1_deviceid"    "蓄电池组1中间点电压不平衡"      "2"    "2"
				add_warning   "$(cat voltage_unbalance1_serial_high_frequency)"    "$voltage_unbalance1_Id"       "$FsuId_All"     "$voltage_unbalance1_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：蓄电池组1中间点电压不平衡"
				echo "0"  >  voltage_unbalance1_alarm_count   #########重新计数
				echo "1"  >  voltage_unbalance1_close    ##########关闭告警
				date +%s  >  voltage_unbalance1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  voltage_unbalance1_serial
				insert_history   "$time"   "$voltage_unbalance1_Id"      "$(cat voltage_unbalance1)"   "$voltage_unbalance1_deviceid"    "蓄电池组1中间点电压不平衡"      "2"    "2"
				add_warning   "$(cat voltage_unbalance1_serial)"    "$voltage_unbalance1_Id"       "$FsuId_All"     "$voltage_unbalance1_deviceid"     "$time"   "2"   "BEGIN"    "蓄电池组1中间点电压不平衡"
			fi	
		else
			if [ $(cat voltage_unbalance1_begin) -eq 1 ];then
			   echo  "0"   >   voltage_unbalance1_begin
			   add_warning   "$(cat voltage_unbalance1_serial)"    "$voltage_unbalance1_Id"       "$FsuId_All"     "$voltage_unbalance1_deviceid"     "$time"   "2"   "END"    "蓄电池组1中间点电压不平衡"
			fi
		fi

		if [ $(echo "$(cat voltage_unbalance1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  voltage_unbalance1_alarm_count   #########重新计数
			date +%s  >  voltage_unbalance1_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat voltage_unbalance1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  voltage_unbalance1_close
			date +%s  >  voltage_unbalance1_open_time       #########记录开始告警时间
			add_warning   "$(cat voltage_unbalance1_serial_high_frequency)"    "$voltage_unbalance1_Id"       "$FsuId_All"     "$voltage_unbalance1_deviceid"     "$time"   "2"   "END"    "高频告警：蓄电池组1中间点电压不平衡"
		fi
	fi
}


voltage_unbalance2_deviceid="42020140700005"
voltage_unbalance2_Id="0407005001"
#######蓄电池组2中间点电压不平衡
function voltage_unbalance2_warn()
{
  	##################记录告警次数######################
	if [ ! -f "voltage_unbalance2_alarm_count" ];then
			echo  "0"   >   voltage_unbalance2_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "voltage_unbalance2_open_time" ];then
			date +%s   >   voltage_unbalance2_open_time
	fi
	
	if [ "$(cat voltage_unbalance2_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################蓄电池组2中间点电压不平衡########################
		if [ $(cat voltage_unbalance2) -eq 1 ];then
			echo  "1"   >   voltage_unbalance2_begin
			echo $((1+$(cat voltage_unbalance2_alarm_count))) >  voltage_unbalance2_alarm_count
			if [ $(cat voltage_unbalance2_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  voltage_unbalance2_serial_high_frequency
				insert_history   "$time"   "$voltage_unbalance2_Id"      "$(cat voltage_unbalance2)"   "$voltage_unbalance2_deviceid"    "蓄电池组2中间点电压不平衡"      "2"    "2"
				add_warning   "$(cat voltage_unbalance2_serial_high_frequency)"    "$voltage_unbalance2_Id"       "$FsuId_All"     "$voltage_unbalance2_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：蓄电池组2中间点电压不平衡"
				echo "0"  >  voltage_unbalance2_alarm_count   #########重新计数
				echo "1"  >  voltage_unbalance2_close    ##########关闭告警
				date +%s  >  voltage_unbalance2_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  voltage_unbalance2_serial
				insert_history   "$time"   "$voltage_unbalance2_Id"      "$(cat voltage_unbalance2)"   "$voltage_unbalance2_deviceid"    "蓄电池组2中间点电压不平衡"      "2"    "2"
				add_warning   "$(cat voltage_unbalance2_serial)"    "$voltage_unbalance2_Id"       "$FsuId_All"     "$voltage_unbalance2_deviceid"     "$time"   "2"   "BEGIN"    "蓄电池组2中间点电压不平衡"
			fi	
		else
			if [ $(cat voltage_unbalance2_begin) -eq 1 ];then
			   echo  "0"   >   voltage_unbalance2_begin
			   add_warning   "$(cat voltage_unbalance2_serial)"    "$voltage_unbalance2_Id"       "$FsuId_All"     "$voltage_unbalance2_deviceid"     "$time"   "2"   "END"    "蓄电池组2中间点电压不平衡"
			fi
		fi

		if [ $(echo "$(cat voltage_unbalance2_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  voltage_unbalance2_alarm_count   #########重新计数
			date +%s  >  voltage_unbalance2_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat voltage_unbalance2_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  voltage_unbalance2_close
			date +%s  >  voltage_unbalance2_open_time       #########记录开始告警时间
			add_warning   "$(cat voltage_unbalance2_serial_high_frequency)"    "$voltage_unbalance2_Id"       "$FsuId_All"     "$voltage_unbalance2_deviceid"     "$time"   "2"   "END"    "高频告警：蓄电池组2中间点电压不平衡"
		fi
	fi
}



##########开关电源设备组#############
##########开关电源设备组#############
battery_melt_alarm_Id="0406001001"
switch_power_deviceid="42020141700002"
#######开关电源电池熔丝故障告警
function battery_melt_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "battery_melt_alarm_alarm_count" ];then
			echo  "0"   >   battery_melt_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "battery_melt_alarm_open_time" ];then
			date +%s   >   battery_melt_alarm_open_time
	fi
	
	if [ "$(cat battery_melt_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################电池熔丝故障告警########################
		if [ $(cat battery_melt_alarm) -eq 1 ];then
			echo  "1"   >   battery_melt_alarm_begin
			echo $((1+$(cat battery_melt_alarm_alarm_count))) >  battery_melt_alarm_alarm_count
			if [ $(cat battery_melt_alarm_alarm_count) -gt 6 ];then
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  battery_melt_alarm_serial_high_frequency
				insert_history   "$time"   "$battery_melt_alarm_Id"      "$(cat battery_melt_alarm)"   "$switch_power_deviceid"    "电池熔丝故障告警"      "2"    "1"
				add_warning   "$(cat battery_melt_alarm_serial_high_frequency)"    "$battery_melt_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "1"   "BEGIN"    "高频告警：电池熔丝故障告警"
				echo "0"  >  battery_melt_alarm_alarm_count   #########重新计数
				echo "1"  >  battery_melt_alarm_close    ##########关闭告警
				date +%s  >  battery_melt_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  battery_melt_alarm_serial
				insert_history   "$time"   "$battery_melt_alarm_Id"      "$(cat battery_melt_alarm)"   "$switch_power_deviceid"    "电池熔丝故障告警"      "2"    "1"
				add_warning   "$(cat battery_melt_alarm_serial)"    "$battery_melt_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "1"   "BEGIN"    "电池熔丝故障告警"
			fi	
		else
			if [ $(cat battery_melt_alarm_begin) -eq 1 ];then
			   echo  "0"   >   battery_melt_alarm_begin
			   add_warning   "$(cat battery_melt_alarm_serial)"    "$battery_melt_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "1"   "END"    "电池熔丝故障告警"
			fi
		fi

		if [ $(echo "$(cat battery_melt_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  battery_melt_alarm_alarm_count   #########重新计数
			date +%s  >  battery_melt_alarm_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat battery_melt_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  battery_melt_alarm_close
			date +%s  >  battery_melt_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat battery_melt_alarm_serial_high_frequency)"    "$battery_melt_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "1"   "END"    "高频告警：电池熔丝故障告警"
		fi
	fi
}

charge_current_over_Id="0406002001"
#######开关电源电池充电过流告警
function charge_current_over_warn()
{
  	##################记录告警次数######################
	if [ ! -f "charge_current_over_alarm_count" ];then
			echo  "0"   >   charge_current_over_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "charge_current_over_open_time" ];then
			date +%s   >   charge_current_over_open_time
	fi
	
	if [ "$(cat charge_current_over_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################电池充电过流告警########################
		if [ $(cat charge_current_over) -eq 1 ];then
			echo  "1"   >   charge_current_over_begin
			echo $((1+$(cat charge_current_over_alarm_count))) >  charge_current_over_alarm_count
			if [ $(cat charge_current_over_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  charge_current_over_serial_high_frequency	
				insert_history   "$time"   "$charge_current_over_Id"      "$(cat charge_current_over)"   "$switch_power_deviceid"    "开关电源电池充电过流告警"      "2"    "3"
				add_warning   "$(cat charge_current_over_serial_high_frequency)"    "$charge_current_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：开关电源电池充电过流告警"
				echo "0"  >  charge_current_over_alarm_count   #########重新计数
				echo "1"  >  charge_current_over_close    ##########关闭告警
				date +%s  >  charge_current_over_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  charge_current_over_serial
				insert_history   "$time"   "$charge_current_over_Id"      "$(cat charge_current_over)"   "$switch_power_deviceid"    "开关电源电池充电过流告警"      "2"    "3"
				add_warning   "$(cat charge_current_over_serial)"    "$charge_current_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "开关电源电池充电过流告警"
			fi	
		else
			if [ $(cat charge_current_over_begin) -eq 1 ];then
			   echo  "0"   >   charge_current_over_begin
			   add_warning   "$(cat charge_current_over_serial)"    "$charge_current_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "开关电源电池充电过流告警"
			fi
		fi

		if [ $(echo "$(cat charge_current_over_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  charge_current_over_alarm_count   #########重新计数
			date +%s  >  charge_current_over_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat charge_current_over_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  charge_current_over_close
			date +%s  >  charge_current_over_open_time       #########记录开始告警时间
			add_warning   "$(cat charge_current_over_serial_high_frequency)"    "$charge_current_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "高频告警：开关电源电池充电过流告警"
		fi
	fi
}

charge_temperature_over_Id="0406003001"
#######开关电源电池温度过高告警
function charge_temperature_over_warn()
{
  	##################记录告警次数######################
	if [ ! -f "charge_temperature_over_alarm_count" ];then
			echo  "0"   >   charge_temperature_over_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "charge_temperature_over_open_time" ];then
			date +%s   >   charge_temperature_over_open_time
	fi
	
	if [ "$(cat charge_temperature_over_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源电池温度过低告警########################
		if [ $(cat charge_temperature_over) -eq 1 ];then
			echo  "1"   >   charge_temperature_over_begin
			echo $((1+$(cat charge_temperature_over_alarm_count))) >  charge_temperature_over_alarm_count
			if [ $(cat charge_temperature_over_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  charge_temperature_over_serial_high_frequency
				insert_history   "$time"   "$charge_temperature_over_Id"      "$(cat charge_temperature_over)"   "$switch_power_deviceid"    "开关电源电池温度过低告警"      "2"    "3"
				add_warning   "$(cat charge_temperature_over_serial_high_frequency)"    "$charge_temperature_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：开关电源电池温度过低告警"
				echo "0"  >  charge_temperature_over_alarm_count   #########重新计数
				echo "1"  >  charge_temperature_over_close    ##########关闭告警
				date +%s  >  charge_temperature_over_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  charge_temperature_over_serial
				insert_history   "$time"   "$charge_temperature_over_Id"      "$(cat charge_temperature_over)"   "$switch_power_deviceid"    "开关电源电池温度过低告警"      "2"    "3"
				add_warning   "$(cat charge_temperature_over_serial)"    "$charge_temperature_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "开关电源电池温度过低告警"
			fi	
		else
			if [ $(cat charge_temperature_over_begin) -eq 1 ];then
			   echo  "0"   >   charge_temperature_over_begin
			   add_warning   "$(cat charge_temperature_over_serial)"    "$charge_temperature_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "开关电源电池温度过低告警"
			fi
		fi

		if [ $(echo "$(cat charge_temperature_over_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  charge_temperature_over_alarm_count   #########重新计数
			date +%s  >  charge_temperature_over_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat charge_temperature_over_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  charge_temperature_over_close
			date +%s  >  charge_temperature_over_open_time       #########记录开始告警时间
			add_warning   "$(cat charge_temperature_over_serial_high_frequency)"    "$charge_temperature_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "高频告警：开关电源电池温度过低告警"
		fi
	fi
}

supply_alarm_Id="0406005001"
#######开关电源处于蓄电池供电状态
function supply_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "supply_alarm_alarm_count" ];then
			echo  "0"   >   supply_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "supply_alarm_open_time" ];then
			date +%s   >   supply_alarm_open_time
	fi
	
	if [ "$(cat supply_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源处于蓄电池供电状态########################
		if [ $(cat supply_alarm) -eq 1 ];then
			echo  "1"   >   supply_alarm_begin
			echo $((1+$(cat supply_alarm_alarm_count))) >  supply_alarm_alarm_count
			if [ $(cat supply_alarm_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  supply_alarm_serial_high_frequency
				insert_history   "$time"   "$supply_alarm_Id"      "$(cat supply_alarm)"   "$switch_power_deviceid"    "开关电源处于蓄电池供电状态"      "2"    "2"
				add_warning   "$(cat supply_alarm_serial_high_frequency)"    "$supply_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：开关电源处于蓄电池供电状态"
				echo "0"  >  supply_alarm_alarm_count   #########重新计数
				echo "1"  >  supply_alarm_close    ##########关闭告警
				date +%s  >  supply_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  supply_alarm_serial
				insert_history   "$time"   "$supply_alarm_Id"      "$(cat supply_alarm)"   "$switch_power_deviceid"    "开关电源处于蓄电池供电状态"      "2"    "2"
				add_warning   "$(cat supply_alarm_serial)"    "$supply_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "开关电源处于蓄电池供电状态"
			fi	
		else
			if [ $(cat supply_alarm_begin) -eq 1 ];then
			   echo  "0"   >   supply_alarm_begin
			   add_warning   "$(cat supply_alarm_serial)"    "$supply_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "开关电源处于蓄电池供电状态"
			fi
		fi

		if [ $(echo "$(cat supply_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  supply_alarm_alarm_count   #########重新计数
			date +%s  >  supply_alarm_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat supply_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  supply_alarm_close
			date +%s  >  supply_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat supply_alarm_serial_high_frequency)"    "$supply_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "高频告警：开关电源处于蓄电池供电状态"
		fi
	fi
}


dc_voltage_output_lower_Id="0406008001" 
#######开关电源直流输出电压过低告警<47
function dc_voltage_output_lower_warn()
{
  	##################记录告警次数######################
	if [ ! -f "dc_voltage_output_lower_alarm_count" ];then
			echo  "0"   >   dc_voltage_output_lower_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "dc_voltage_output_lower_open_time" ];then
			date +%s   >   dc_voltage_output_lower_open_time
	fi
	
	if [ "$(cat dc_voltage_output_lower_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源直流输出电压过低告警########################
		if [ $(cat dc_voltage_output_lower) -eq 1 ];then
			echo  "1"   >   dc_voltage_output_lower_begin
			echo $((1+$(cat dc_voltage_output_lower_alarm_count))) >  dc_voltage_output_lower_alarm_count
			if [ $(cat dc_voltage_output_lower_alarm_count) -gt 6 ];then   
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  dc_voltage_output_lower_serial_high_frequency	
				insert_history   "$time"   "$dc_voltage_output_lower_Id"      "$(cat dc_voltage_output_lower)"   "$switch_power_deviceid"    "开关电源直流输出电压过低告警"      "2"    "2"
				add_warning   "$(cat dc_voltage_output_lower_serial_high_frequency)"    "$dc_voltage_output_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：开关电源直流输出电压过低告警"
				echo "0"  >  dc_voltage_output_lower_alarm_count   #########重新计数
				echo "1"  >  dc_voltage_output_lower_close    ##########关闭告警
				date +%s  >  dc_voltage_output_lower_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$dc_voltage_output_lower_Id"      "$(cat dc_voltage_output_lower)"   "$switch_power_deviceid"    "开关电源直流输出电压过低告警"      "2"    "2"
				cat Serial_No5  >  dc_voltage_output_lower_serial
				add_warning   "$(cat dc_voltage_output_lower_serial)"    "$dc_voltage_output_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "开关电源直流输出电压过低告警"
			fi	
		else
			if [ $(cat dc_voltage_output_lower_begin) -eq 1 ];then
			   echo  "0"   >   dc_voltage_output_lower_begin
			   add_warning   "$(cat dc_voltage_output_lower_serial)"    "$dc_voltage_output_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "开关电源直流输出电压过低告警,开关电源直流输出电压过低告警标志位为$(cat dc_voltage_output_lower)"
			fi
		fi

		if [ $(echo "$(cat dc_voltage_output_lower_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  dc_voltage_output_lower_alarm_count   #########重新计数
			date +%s  >  dc_voltage_output_lower_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat dc_voltage_output_lower_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  dc_voltage_output_lower_close
			date +%s  >  dc_voltage_output_lower_open_time       #########记录开始告警时间
			add_warning   "$(cat dc_voltage_output_lower_serial_high_frequency)"    "$dc_voltage_output_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "高频告警：开关电源直流输出电压过低告警"
		fi
	fi
}


dc_voltage_output_higher_Id="0406009001"
#######开关电源直流输出电压过高告警>57.5
function dc_voltage_output_higher_warn()
{
  	##################记录告警次数######################
	if [ ! -f "dc_voltage_output_higher_alarm_count" ];then
			echo  "0"   >   dc_voltage_output_higher_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "dc_voltage_output_higher_open_time" ];then
			date +%s   >   dc_voltage_output_higher_open_time
	fi
	
	if [ "$(cat dc_voltage_output_higher_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源直流输出电压过低告警########################
		if [ $(cat dc_voltage_output_higher) -eq 1 ];then
			echo  "1"   >   dc_voltage_output_higher_begin
			echo $((1+$(cat dc_voltage_output_higher_alarm_count))) >  dc_voltage_output_higher_alarm_count
			if [ $(cat dc_voltage_output_higher_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  dc_voltage_output_higher_serial_high_frequency
				insert_history   "$time"   "$dc_voltage_output_higher_Id"      "$(cat dc_voltage_output_higher)"   "$switch_power_deviceid"    "开关电源直流输出电压过低告警"      "2"    "4"
				add_warning   "$(cat dc_voltage_output_higher_serial_high_frequency)"    "$dc_voltage_output_higher_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "高频告警：开关电源直流输出电压过低告警"
				echo "0"  >  dc_voltage_output_higher_alarm_count   #########重新计数
				echo "1"  >  dc_voltage_output_higher_close    ##########关闭告警
				date +%s  >  dc_voltage_output_higher_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  dc_voltage_output_higher_serial
				insert_history   "$time"   "$dc_voltage_output_higher_Id"      "$(cat dc_voltage_output_higher)"   "42020141800001"    "开关电源直流输出电压过低告警"      "2"    "4"
				add_warning   "$(cat dc_voltage_output_higher_serial)"    "$dc_voltage_output_higher_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "开关电源直流输出电压过低告警"
			fi	
		else
			if [ $(cat dc_voltage_output_higher_begin) -eq 1 ];then
			   echo  "0"   >   dc_voltage_output_higher_begin
			   add_warning   "$(cat dc_voltage_output_higher_serial)"    "$dc_voltage_output_higher_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "开关电源直流输出电压过低告警"
			fi
		fi

		if [ $(echo "$(cat dc_voltage_output_higher_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  dc_voltage_output_higher_alarm_count   #########重新计数
			date +%s  >  dc_voltage_output_higher_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat dc_voltage_output_higher_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  dc_voltage_output_higher_close
			date +%s  >  dc_voltage_output_higher_open_time       #########记录开始告警时间
			add_warning   "$(cat dc_voltage_output_higher_serial_high_frequency)"    "$dc_voltage_output_higher_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "高频告警：开关电源直流输出电压过低告警"
		fi
	fi
}


ac_voltage_input_over_Id="0406014001"
#######开关电源交流输入电压过高告警>275
function ac_voltage_input_over_warn()
{
  	##################记录告警次数######################
	if [ ! -f "ac_voltage_input_over_alarm_count" ];then
			echo  "0"   >   ac_voltage_input_over_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "ac_voltage_input_over_open_time" ];then
			date +%s   >   ac_voltage_input_over_open_time
	fi
	
	if [ "$(cat ac_voltage_input_over_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源交流输入电压过低告警########################
		if [ $(cat ac_voltage_input_over) -eq 1 ];then
			echo  "1"   >   ac_voltage_input_over_begin
			echo $((1+$(cat ac_voltage_input_over_alarm_count))) >  ac_voltage_input_over_alarm_count
			if [ $(cat ac_voltage_input_over_alarm_count) -gt 6 ];then     
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_voltage_input_over_serial_high_frequency
				insert_history   "$time"   "$ac_voltage_input_over_Id"      "$(cat ac_voltage_input_over)"   "$switch_power_deviceid"    "开关电源交流输入电压过低告警"      "2"    "4"
				add_warning   "$(cat ac_voltage_input_over_serial_high_frequency)"    "$ac_voltage_input_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "高频告警：开关电源交流输入电压过低告警"
				echo "0"  >  ac_voltage_input_over_alarm_count   #########重新计数
				echo "1"  >  ac_voltage_input_over_close    ##########关闭告警
				date +%s  >  ac_voltage_input_over_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_voltage_input_over_serial
				insert_history   "$time"   "$ac_voltage_input_over_Id"      "$(cat ac_voltage_input_over)"   "$switch_power_deviceid"    "开关电源交流输入电压过低告警"      "2"    "4"
				add_warning   "$(cat ac_voltage_input_over_serial)"    "$ac_voltage_input_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "开关电源交流输入电压过低告警"
			fi	
		else
			if [ $(cat ac_voltage_input_over_begin) -eq 1 ];then
			   echo  "0"   >   ac_voltage_input_over_begin
			   add_warning   "$(cat ac_voltage_input_over_serial)"    "$ac_voltage_input_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "开关电源交流输入电压过低告警"
			fi
		fi

		if [ $(echo "$(cat ac_voltage_input_over_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_voltage_input_over_alarm_count   #########重新计数
			date +%s  >  ac_voltage_input_over_open_time       #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat ac_voltage_input_over_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_voltage_input_over_close
			date +%s  >  ac_voltage_input_over_open_time       #########记录开始告警时间
			add_warning   "$(cat ac_voltage_input_over_serial_high_frequency)"    "$ac_voltage_input_over_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "高频告警：开关电源交流输入电压过低告警"
		fi
	fi
}


ac_voltage_input_lower_Id="0406015001" 
#######开关电源交流输入电压过低告警<176
function ac_voltage_input_lower_warn()
{
  	##################记录告警次数######################
	if [ ! -f "ac_voltage_input_lower_alarm_count" ];then
			echo  "0"   >   ac_voltage_input_lower_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "ac_voltage_input_lower_open_time" ];then
			date +%s   >   ac_voltage_input_lower_open_time
	fi
	
	if [ "$(cat ac_voltage_input_lower_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源交流输入电压过低告警########################
		if [ $(cat ac_voltage_input_lower) -eq 1 ];then
			echo  "1"   >   ac_voltage_input_lower_begin
			echo $((1+$(cat ac_voltage_input_lower_alarm_count))) >  ac_voltage_input_lower_alarm_count
			if [ $(cat ac_voltage_input_lower_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_voltage_input_lower_serial_high_frequency
				insert_history   "$time"   "$ac_voltage_input_lower_Id"      "$(cat ac_voltage_input_lower)"   "42020141800001"    "开关电源交流输入电压过低告警"      "2"    "4"
				add_warning   "$(cat ac_voltage_input_lower_serial_high_frequency)"    "$ac_voltage_input_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "高频告警：开关电源交流输入电压过低告警"
				echo "0"  >  ac_voltage_input_lower_alarm_count   #########重新计数
				echo "1"  >  ac_voltage_input_lower_close    ##########关闭告警
				date +%s  >  ac_voltage_input_lower_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_voltage_input_lower_serial
				insert_history   "$time"   "$ac_voltage_input_lower_Id"      "$(cat ac_voltage_input_lower)"   "switch_power_deviceid"    "开关电源交流输入电压过低告警"      "2"    "4"
				add_warning   "$(cat ac_voltage_input_lower_serial)"    "$ac_voltage_input_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "开关电源交流输入电压过低告警"
			fi	
		else
			if [ $(cat ac_voltage_input_lower_begin) -eq 1 ];then
			   echo  "0"   >   ac_voltage_input_lower_begin
			   add_warning   "$(cat ac_voltage_input_lower_serial)"    "$ac_voltage_input_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "开关电源交流输入电压过低告警"
			fi
		fi

		if [ $(echo "$(cat ac_voltage_input_lower_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_voltage_input_lower_alarm_count     #########重新计数
			date +%s  >  ac_voltage_input_lower_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat ac_voltage_input_lower_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_voltage_input_lower_close
			date +%s  >  ac_voltage_input_lower_open_time       #########记录开始告警时间
			add_warning   "$(cat ac_voltage_input_lower_serial_high_frequency)"    "$ac_voltage_input_lower_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "高频告警：开关电源交流输入电压过低告警"
		fi
	fi
}


ac_input_stopped_Id="0406016001" 
#######开关电源交流输入停电告警
function ac_input_stopped_warn()
{
  	##################记录告警次数######################
	if [ ! -f "ac_input_stopped_alarm_count" ];then
			echo  "0"   >   ac_input_stopped_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "ac_input_stopped_open_time" ];then
			date +%s   >   ac_input_stopped_open_time
	fi
	
	if [ "$(cat ac_input_stopped_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源交流输入停电告警########################
		if [ $(cat ac_input_stopped) -eq 1 ];then
			echo  "1"   >   ac_input_stopped_begin
			echo $((1+$(cat ac_input_stopped_alarm_count))) >  ac_input_stopped_alarm_count
			if [ $(cat ac_input_stopped_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_input_stopped_serial_high_frequency
				insert_history   "$time"   "$ac_input_stopped_Id"      "$(cat ac_input_stopped)"   "switch_power_deviceid"    "开关电源交流输入停电告警"      "2"    "2"
				add_warning   "$(cat ac_input_stopped_serial_high_frequency)"    "$ac_input_stopped_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：开关电源交流输入停电告警"
				echo "0"  >  ac_input_stopped_alarm_count   #########重新计数
				echo "1"  >  ac_input_stopped_close    ##########关闭告警
				date +%s  >  ac_input_stopped_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_input_stopped_serial
				insert_history   "$time"   "$ac_input_stopped_Id"      "$(cat ac_input_stopped)"   "switch_power_deviceid"    "开关电源交流输入停电告警"      "2"    "2"
				add_warning   "$(cat ac_input_stopped_serial)"    "$ac_input_stopped_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "开关电源交流输入停电告警"
			fi	
		else
			if [ $(cat ac_input_stopped_begin) -eq 1 ];then
			   echo  "0"   >   ac_input_stopped_begin
			   add_warning   "$(cat ac_input_stopped_serial)"    "$ac_input_stopped_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "开关电源交流输入停电告警"
			fi
		fi

		if [ $(echo "$(cat ac_input_stopped_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_input_stopped_alarm_count     #########重新计数
			date +%s  >  ac_input_stopped_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat ac_input_stopped_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_input_stopped_close
			date +%s  >  ac_input_stopped_open_time       #########记录开始告警时间
			add_warning   "$(cat ac_input_stopped_serial_high_frequency)"    "$ac_input_stopped_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "高频告警：开关电源交流输入停电告警"
		fi
	fi
}


ac_input_phase_lost_Id="0406017001"
#######开关电源交流输入缺相告警
function ac_input_phase_lost_warn()
{
  	##################记录告警次数######################
	if [ ! -f "ac_input_phase_lost_alarm_count" ];then
			echo  "0"   >   ac_input_phase_lost_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "ac_input_phase_lost_open_time" ];then
			date +%s   >   ac_input_phase_lost_open_time
	fi
	
	if [ "$(cat ac_input_phase_lost_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源交流输入缺相告警########################
		if [ $(cat ac_input_phase_lost) -eq 1 ];then
			echo  "1"   >   ac_input_phase_lost_begin
			echo $((1+$(cat ac_input_phase_lost_alarm_count))) >  ac_input_phase_lost_alarm_count
			if [ $(cat ac_input_phase_lost_alarm_count) -gt 6 ];then    
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_input_phase_lost_serial_high_frequency
				insert_history   "$time"   "$ac_input_phase_lost_Id"      "$(cat ac_input_phase_lost)"   "switch_power_deviceid"    "开关电源交流输入缺相告警"      "2"    "2"
				add_warning   "$(cat ac_input_phase_lost_serial_high_frequency)"    "$ac_input_phase_lost_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "高频告警：开关电源交流输入缺相告警"
				echo "0"  >  ac_input_phase_lost_alarm_count   #########重新计数
				echo "1"  >  ac_input_phase_lost_close    ##########关闭告警
				date +%s  >  ac_input_phase_lost_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  ac_input_phase_lost_serial
				insert_history   "$time"   "$ac_input_phase_lost_Id"      "$(cat ac_input_phase_lost)"   "switch_power_deviceid"    "开关电源交流输入缺相告警"      "2"    "2"
				add_warning   "$(cat ac_input_phase_lost_serial)"    "$ac_input_phase_lost_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "BEGIN"    "开关电源交流输入缺相告警"
			fi	
		else
			if [ $(cat ac_input_phase_lost_begin) -eq 1 ];then
			   echo  "0"   >   ac_input_phase_lost_begin
			   add_warning   "$(cat ac_input_phase_lost_serial)"    "$ac_input_phase_lost_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "开关电源交流输入缺相告警"
			fi
		fi

		if [ $(echo "$(cat ac_input_phase_lost_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_input_phase_lost_alarm_count     #########重新计数
			date +%s  >  ac_input_phase_lost_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat ac_input_phase_lost_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  ac_input_phase_lost_close
			date +%s  >  ac_input_phase_lost_open_time       #########记录开始告警时间
			add_warning   "$(cat ac_input_phase_lost_serial_high_frequency)"    "$ac_input_phase_lost_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "高频告警：开关电源交流输入缺相告警"
		fi
	fi
}


lightning_arrester_alarm_Id="0406022001"
#######开关电源防雷器故障告警
function lightning_arrester_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "lightning_arrester_alarm_alarm_count" ];then
			echo  "0"   >   lightning_arrester_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "lightning_arrester_alarm_open_time" ];then
			date +%s   >   lightning_arrester_alarm_open_time
	fi
	
	if [ "$(cat lightning_arrester_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源交流输入缺相告警########################
		if [ $(cat lightning_arrester_alarm) -eq 1 ];then
			echo  "1"   >   lightning_arrester_alarm_begin
			echo $((1+$(cat lightning_arrester_alarm_alarm_count))) >  lightning_arrester_alarm_alarm_count
			if [ $(cat lightning_arrester_alarm_alarm_count) -gt 6 ];then       
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  lightning_arrester_alarm_serial_high_frequency
				insert_history   "$time"   "$lightning_arrester_alarm_Id"      "$(cat lightning_arrester_alarm)"   "switch_power_deviceid"    "开关电源防雷器故障告警"      "2"    "4"
				add_warning   "$(cat lightning_arrester_alarm_serial_high_frequency)"    "$lightning_arrester_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "高频告警：开关电源防雷器故障告警"
				echo "0"  >  lightning_arrester_alarm_alarm_count   #########重新计数
				echo "1"  >  lightning_arrester_alarm_close    ##########关闭告警
				date +%s  >  lightning_arrester_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  lightning_arrester_alarm_serial	
				insert_history   "$time"   "$lightning_arrester_alarm_Id"      "$(cat lightning_arrester_alarm)"   "switch_power_deviceid"    "开关电源防雷器故障告警"      "2"    "4"
				add_warning   "$(cat lightning_arrester_alarm_serial)"    "$lightning_arrester_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "BEGIN"    "开关电源防雷器故障告警"
			fi	
		else
			if [ $(cat lightning_arrester_alarm_begin) -eq 1 ];then
			   echo  "0"   >   lightning_arrester_alarm_begin
			   add_warning   "$(cat lightning_arrester_alarm_serial)"    "$lightning_arrester_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "4"   "END"    "开关电源防雷器故障告警"
			fi
		fi

		if [ $(echo "$(cat lightning_arrester_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  lightning_arrester_alarm_alarm_count     #########重新计数
			date +%s  >  lightning_arrester_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat lightning_arrester_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  lightning_arrester_alarm_close
			date +%s  >  lightning_arrester_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat lightning_arrester_alarm_serial_high_frequency)"    "$lightning_arrester_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "2"   "END"    "高频告警：开关电源防雷器故障告警"
		fi
	fi
}


rectifier_module_alarm_Id="0406024001"
#######开关电源整流模块故障告警
function rectifier_module_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "rectifier_module_alarm_alarm_count" ];then
			echo  "0"   >   rectifier_module_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "rectifier_module_alarm_open_time" ];then
			date +%s   >   rectifier_module_alarm_open_time
	fi
	
	if [ "$(cat rectifier_module_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源整流模块故障告警########################
		if [ $(cat rectifier_module_alarm) -eq 1 ];then
			echo  "1"   >   rectifier_module_alarm_begin
			echo $((1+$(cat rectifier_module_alarm_alarm_count))) >  rectifier_module_alarm_alarm_count
			if [ $(cat rectifier_module_alarm_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  rectifier_module_alarm_serial_high_frequency
				insert_history   "$time"   "$rectifier_module_alarm_Id"      "$(cat rectifier_module_alarm)"   "switch_power_deviceid"    "开关电源整流模块故障告警"      "2"    "3"
				add_warning   "$(cat rectifier_module_alarm_serial_high_frequency)"    "$rectifier_module_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：开关电源整流模块故障告警"
				echo "0"  >  rectifier_module_alarm_alarm_count   #########重新计数
				echo "1"  >  rectifier_module_alarm_close    ##########关闭告警
				date +%s  >  rectifier_module_alarm_close_time       #########记录关闭告警时间
			else 
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$rectifier_module_alarm_Id"      "$(cat rectifier_module_alarm)"   "switch_power_deviceid"    "开关电源整流模块故障告警"      "2"    "3"
				cat Serial_No5  >  rectifier_module_alarm_serial
				add_warning   "$(cat rectifier_module_alarm_serial)"    "$rectifier_module_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "开关电源整流模块故障告警"
			fi	
		else
			if [ $(cat rectifier_module_alarm_begin) -eq 1 ];then
			   echo  "0"   >   rectifier_module_alarm_begin
			   add_warning   "$(cat rectifier_module_alarm_serial)"    "$rectifier_module_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "开关电源整流模块故障告警"
			fi
		fi

		if [ $(echo "$(cat rectifier_module_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  rectifier_module_alarm_alarm_count     #########重新计数
			date +%s  >  rectifier_module_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat rectifier_module_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  rectifier_module_alarm_close
			date +%s  >  rectifier_module_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat rectifier_module_alarm_serial_high_frequency)"    "$rectifier_module_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "高频告警：开关电源整流模块故障告警"
		fi
	fi
}


rectifier_communication_alarm_Id="0406028001"
#######开关电源整流模块通信状态故障告警
function rectifier_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "rectifier_communication_alarm_alarm_count" ];then
			echo  "0"   >   rectifier_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "rectifier_communication_alarm_open_time" ];then
			date +%s   >   rectifier_communication_alarm_open_time
	fi
	
	if [ "$(cat rectifier_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源整流模块通信状态故障告警########################
		if [ $(cat rectifier_communication_alarm) -eq 1 ];then
			echo  "1"   >   rectifier_communication_alarm_begin
			echo $((1+$(cat rectifier_communication_alarm_alarm_count))) >  rectifier_communication_alarm_alarm_count
			if [ $(cat rectifier_communication_alarm_alarm_count) -gt 6 ];then 
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  rectifier_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$rectifier_communication_alarm_Id"      "$(cat rectifier_communication_alarm)"   "switch_power_deviceid"    "开关电源整流模块通信状态故障告警"      "2"    "3"
				add_warning   "$(cat rectifier_communication_alarm_serial_high_frequency)"    "$rectifier_communication_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：开关电源整流模块通信状态故障告警"
				echo "0"  >  rectifier_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  rectifier_communication_alarm_close    ##########关闭告警
				date +%s  >  rectifier_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$rectifier_communication_alarm_Id"      "$(cat rectifier_communication_alarm)"   "switch_power_deviceid"    "开关电源整流模块通信状态故障告警"      "2"    "3"
				cat Serial_No5  >  rectifier_communication_alarm_serial	
				add_warning   "$(cat rectifier_communication_alarm_serial)"    "$rectifier_communication_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "BEGIN"    "开关电源整流模块通信状态故障告警"
			fi	
		else
			if [ $(cat rectifier_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   rectifier_communication_alarm_begin
			   add_warning   "$(cat rectifier_communication_alarm_serial)"    "$rectifier_communication_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "开关电源整流模块通信状态故障告警"
			fi
		fi

		if [ $(echo "$(cat rectifier_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  rectifier_communication_alarm_alarm_count     #########重新计数
			date +%s  >  rectifier_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat rectifier_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  rectifier_communication_alarm_close
			date +%s  >  rectifier_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat rectifier_communication_alarm_serial_high_frequency)"    "$rectifier_communication_alarm_Id"       "$FsuId_All"     "$switch_power_deviceid"     "$time"   "3"   "END"    "高频告警：开关电源整流模块通信状态故障告警"
		fi
	fi
}


###############空调设备组###############
###############空调设备组###############
AirConditionDeviceID="42020141500003"
air_condition_abnormal_alarm_Id="0415001001"
#######空调工作异常告警
function air_condition_abnormal_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "air_condition_abnormal_alarm_alarm_count" ];then
			echo  "0"   >   air_condition_abnormal_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "air_condition_abnormal_alarm_open_time" ];then
			date +%s   >   air_condition_abnormal_alarm_open_time
	fi
	
	if [ "$(cat air_condition_abnormal_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################空调工作异常告警########################
		if [ $(cat air_condition_abnormal_alarm) -eq 1 ];then
			echo  "1"   >   air_condition_abnormal_alarm_begin
			echo $((1+$(cat air_condition_abnormal_alarm_alarm_count))) >  air_condition_abnormal_alarm_alarm_count
			if [ $(cat air_condition_abnormal_alarm_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  air_condition_abnormal_alarm_serial_high_frequency
				insert_history   "$time"   "$air_condition_abnormal_alarm_Id"      "$(cat air_condition_abnormal_alarm)"   "$AirConditionDeviceID"    "空调工作异常告警"      "2"    "4"
				add_warning   "$(cat air_condition_abnormal_alarm_serial_high_frequency)"    "$air_condition_abnormal_alarm_Id"       "$FsuId_All"     "$AirConditionDeviceID"     "$time"   "4"   "BEGIN"    "高频告警：空调工作异常告警"
				echo "0"  >  air_condition_abnormal_alarm_alarm_count   #########重新计数
				echo "1"  >  air_condition_abnormal_alarm_close    ##########关闭告警
				date +%s  >  air_condition_abnormal_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  air_condition_abnormal_alarm_serial
				insert_history   "$time"   "$air_condition_abnormal_alarm_Id"      "$(cat air_condition_abnormal_alarm)"   "$AirConditionDeviceID"    "空调工作异常告警"      "2"    "4"
				add_warning   "$(cat air_condition_abnormal_alarm_serial)"    "$air_condition_abnormal_alarm_Id"       "$FsuId_All"     "$AirConditionDeviceID"     "$time"   "4"   "BEGIN"    "空调工作异常告警"
			fi	
		else
			if [ $(cat air_condition_abnormal_alarm_begin) -eq 1 ];then
			   echo  "0"   >   air_condition_abnormal_alarm_begin
			   add_warning   "$(cat air_condition_abnormal_alarm_serial)"    "$air_condition_abnormal_alarm_Id"       "$FsuId_All"     "$AirConditionDeviceID"     "$time"   "4"   "END"    "空调工作异常告警"
			fi
		fi

		if [ $(echo "$(cat air_condition_abnormal_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  air_condition_abnormal_alarm_alarm_count     #########重新计数
			date +%s  >  air_condition_abnormal_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat air_condition_abnormal_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  air_condition_abnormal_alarm_close
			date +%s  >  air_condition_abnormal_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat air_condition_abnormal_alarm_serial_high_frequency)"    "$air_condition_abnormal_alarm_Id"       "$FsuId_All"     "$AirConditionDeviceID"     "$time"   "4"   "END"    "高频告警：空调工作异常告警"
		fi
	fi
}



###############通信状态监测设备组###############
###############通信状态监测设备组###############
MonitorStatusDeviceID="42020141900002"
spower_communication_alarm_Id="0419006001"
#######开关电源通信状态告警
function spower_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "spower_communication_alarm_alarm_count" ];then
			echo  "0"   >   spower_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "spower_communication_alarm_open_time" ];then
			date +%s   >   spower_communication_alarm_open_time
	fi
	
	if [ "$(cat spower_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################开关电源通信状态告警########################
		if [ $(cat spower_communication_alarm) -eq 1 ];then
			echo  "1"   >   spower_communication_alarm_begin
			echo $((1+$(cat spower_communication_alarm_alarm_count))) >  spower_communication_alarm_alarm_count
			if [ $(cat spower_communication_alarm_alarm_count) -gt 6 ];then     
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  spower_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$spower_communication_alarm_Id"      "$(cat spower_communication_alarm)"   "$MonitorStatusDeviceID"    "开关电源通信状态告警"      "2"    "3"
				add_warning   "$(cat spower_communication_alarm_serial_high_frequency)"    "$spower_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "高频告警：开关电源通信状态告警"
				echo "0"  >  spower_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  spower_communication_alarm_close    ##########关闭告警
				date +%s  >  spower_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  spower_communication_alarm_serial	
				insert_history   "$time"   "$spower_communication_alarm_Id"      "$(cat spower_communication_alarm)"   "$MonitorStatusDeviceID"    "开关电源通信状态告警"      "2"    "3"
				add_warning   "$(cat spower_communication_alarm_serial)"    "$spower_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "开关电源通信状态告警"
			fi	
		else
			if [ $(cat spower_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   spower_communication_alarm_begin
			   add_warning   "$(cat spower_communication_alarm_serial)"    "$spower_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "END"    "开关电源通信状态告警"
			fi
		fi

		if [ $(echo "$(cat spower_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  spower_communication_alarm_alarm_count     #########重新计数
			date +%s  >  spower_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat spower_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  spower_communication_alarm_close
			date +%s  >  spower_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat spower_communication_alarm_serial_high_frequency)"    "$spower_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "END"    "高频告警：开关电源通信状态告警"
		fi
	fi
}


aircon_communication_alarm_Id="0419008001"
#######普通空调通信状态告警
function aircon_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "aircon_communication_alarm_alarm_count" ];then
			echo  "0"   >   aircon_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "aircon_communication_alarm_open_time" ];then
			date +%s   >   aircon_communication_alarm_open_time
	fi
	
	if [ "$(cat aircon_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################普通空调通信状态告警########################
		if [ $(cat aircon_communication_alarm) -eq 1 ];then
			echo  "1"   >   aircon_communication_alarm_begin
			echo $((1+$(cat aircon_communication_alarm_alarm_count))) >  aircon_communication_alarm_alarm_count
			if [ $(cat aircon_communication_alarm_alarm_count) -gt 6 ];then   
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  aircon_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$aircon_communication_alarm_Id"      "$(cat aircon_communication_alarm)"   "$MonitorStatusDeviceID"    "普通空调通信状态告警"      "2"    "4"
				add_warning   "$(cat aircon_communication_alarm_serial_high_frequency)"    "$aircon_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "BEGIN"    "高频告警：普通空调通信状态告警"
				echo "0"  >  aircon_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  aircon_communication_alarm_close    ##########关闭告警
				date +%s  >  aircon_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  aircon_communication_alarm_serial
				insert_history   "$time"   "$aircon_communication_alarm_Id"      "$(cat aircon_communication_alarm)"   "$MonitorStatusDeviceID"    "普通空调通信状态告警"      "2"    "4"
				add_warning   "$(cat aircon_communication_alarm_serial)"    "$aircon_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "BEGIN"    "普通空调通信状态告警"
			fi	
		else
			if [ $(cat aircon_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   aircon_communication_alarm_begin
			   add_warning   "$(cat aircon_communication_alarm_serial)"    "$aircon_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "END"    "普通空调通信状态告警"
			fi
		fi

		if [ $(echo "$(cat aircon_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  aircon_communication_alarm_alarm_count     #########重新计数
			date +%s  >  aircon_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat aircon_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  aircon_communication_alarm_close
			date +%s  >  aircon_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat aircon_communication_alarm_serial_high_frequency)"    "$aircon_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "END"    "高频告警：普通空调通信状态告警"
		fi
	fi
}



smameter_communication_alarm_Id="0419012001" 
#######智能电表通信中断告警告警
function smameter_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "smameter_communication_alarm_alarm_count" ];then
			echo  "0"   >   smameter_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "smameter_communication_alarm_open_time" ];then
			date +%s   >   smameter_communication_alarm_open_time
	fi
	
	if [ "$(cat smameter_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################智能电表通信中断告警告警########################
		if [ $(cat smameter_communication_alarm) -eq 1 ];then
			echo  "1"   >   smameter_communication_alarm_begin
			echo $((1+$(cat smameter_communication_alarm_alarm_count))) >  smameter_communication_alarm_alarm_count
			if [ $(cat smameter_communication_alarm_alarm_count) -gt 6 ];then     
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  smameter_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$smameter_communication_alarm_Id"      "$(cat smameter_communication_alarm)"   "$MonitorStatusDeviceID"    "智能电表通信中断告警告警"      "2"    "3"
				add_warning   "$(cat smameter_communication_alarm_serial_high_frequency)"    "$smameter_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "高频告警：智能电表通信中断告警告警"
				echo "0"  >  smameter_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  smameter_communication_alarm_close    ##########关闭告警
				date +%s  >  smameter_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  smameter_communication_alarm_serial
				insert_history   "$time"   "$smameter_communication_alarm_Id"      "$(cat smameter_communication_alarm)"   "$MonitorStatusDeviceID"    "智能电表通信中断告警告警"      "2"    "3"
				add_warning   "$(cat smameter_communication_alarm_serial)"    "$smameter_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "智能电表通信中断告警告警"
			fi	
		else
			if [ $(cat smameter_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   smameter_communication_alarm_begin
			   add_warning   "$(cat smameter_communication_alarm_serial)"    "$smameter_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "END"    "智能电表通信中断告警告警"
			fi
		fi

		if [ $(echo "$(cat smameter_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  smameter_communication_alarm_alarm_count     #########重新计数
			date +%s  >  smameter_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat smameter_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  smameter_communication_alarm_close
			date +%s  >  smameter_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat smameter_communication_alarm_serial_high_frequency)"    "$smameter_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "END"    "高频告警：智能电表通信中断告警告警"
		fi
	fi
}


smaguard_communication_alarm_Id="0419013001" 
#######智能门禁通信状态告警
function smaguard_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "smaguard_communication_alarm_alarm_count" ];then
			echo  "0"   >   smaguard_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "smaguard_communication_alarm_open_time" ];then
			date +%s   >   smaguard_communication_alarm_open_time
	fi
	
	if [ "$(cat smaguard_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################智能门禁通信状态告警########################
		if [ $(cat smaguard_communication_alarm) -eq 1 ];then
			echo  "1"   >   smaguard_communication_alarm_begin
			echo $((1+$(cat smaguard_communication_alarm_alarm_count))) >  smaguard_communication_alarm_alarm_count
			if [ $(cat smaguard_communication_alarm_alarm_count) -gt 6 ];then     
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  smaguard_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$smaguard_communication_alarm_Id"      "$(cat smaguard_communication_alarm)"   "$MonitorStatusDeviceID"    "智能门禁通信状态告警"      "2"    "3"
				add_warning   "$(cat smaguard_communication_alarm_serial_high_frequency)"    "$smaguard_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "高频告警：智能门禁通信状态告警"
				echo "0"  >  smaguard_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  smaguard_communication_alarm_close    ##########关闭告警
				date +%s  >  smaguard_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  smaguard_communication_alarm_serial
				insert_history   "$time"   "$smaguard_communication_alarm_Id"      "$(cat smaguard_communication_alarm)"   "$MonitorStatusDeviceID"    "智能门禁通信状态告警"      "2"    "3"
				add_warning   "$(cat smaguard_communication_alarm_serial)"    "$smaguard_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "BEGIN"    "智能门禁通信状态告警"
			fi	
		else
			if [ $(cat smaguard_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   smaguard_communication_alarm_begin
			   add_warning   "$(cat smaguard_communication_alarm_serial)"    "$smaguard_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "3"   "END"    "智能门禁通信状态告警"
			fi
		fi

		if [ $(echo "$(cat smaguard_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  smaguard_communication_alarm_alarm_count     #########重新计数
			date +%s  >  smaguard_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat smaguard_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  smaguard_communication_alarm_close
			date +%s  >  smaguard_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat smaguard_communication_alarm_serial_high_frequency)"    "$smaguard_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "2"   "END"    "高频告警：智能门禁通信状态告警"
		fi
	fi
}



heatswap_communication_alarm_Id="0419009001"
#######通风/换热设备通信状态告警
function heatswap_communication_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "heatswap_communication_alarm_alarm_count" ];then
			echo  "0"   >   heatswap_communication_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "heatswap_communication_alarm_open_time" ];then
			date +%s   >   heatswap_communication_alarm_open_time
	fi
	
	if [ "$(cat heatswap_communication_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################通风/换热设备通信状态告警########################
		if [ $(cat heatswap_communication_alarm) -eq 1 ];then
			echo  "1"   >   heatswap_communication_alarm_begin
			echo $((1+$(cat heatswap_communication_alarm_alarm_count))) >  heatswap_communication_alarm_alarm_count
			if [ $(cat heatswap_communication_alarm_alarm_count) -gt 6 ];then       
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  heatswap_communication_alarm_serial_high_frequency
				insert_history   "$time"   "$heatswap_communication_alarm_Id"      "$(cat heatswap_communication_alarm)"   "$MonitorStatusDeviceID"    "通风/换热设备通信状态告警"      "2"    "4"
				add_warning   "$(cat heatswap_communication_alarm_serial_high_frequency)"    "$heatswap_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "BEGIN"    "高频告警：通风/换热设备通信状态告警"
				echo "0"  >  heatswap_communication_alarm_alarm_count   #########重新计数
				echo "1"  >  heatswap_communication_alarm_close    ##########关闭告警
				date +%s  >  heatswap_communication_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  heatswap_communication_alarm_serial
				insert_history   "$time"   "$heatswap_communication_alarm_Id"      "$(cat heatswap_communication_alarm)"   "$MonitorStatusDeviceID"    "通风/换热设备通信状态告警"      "2"    "4"
				add_warning   "$(cat heatswap_communication_alarm_serial)"    "$heatswap_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "BEGIN"    "通风/换热设备通信状态告警"
			fi	
		else
			if [ $(cat heatswap_communication_alarm_begin) -eq 1 ];then
			   echo  "0"   >   heatswap_communication_alarm_begin
			   add_warning   "$(cat heatswap_communication_alarm_serial)"    "$heatswap_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "END"    "通风/换热设备通信状态告警"
			fi
		fi

		if [ $(echo "$(cat heatswap_communication_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  heatswap_communication_alarm_alarm_count     #########重新计数
			date +%s  >  heatswap_communication_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat heatswap_communication_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  heatswap_communication_alarm_close
			date +%s  >  heatswap_communication_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat heatswap_communication_alarm_serial_high_frequency)"    "$heatswap_communication_alarm_Id"       "$FsuId_All"     "$MonitorStatusDeviceID"     "$time"   "4"   "END"    "高频告警：通风/换热设备通信状态告警"
		fi
	fi
}


###############热交换设备组###############
###############热交换设备组###############
HeatSwapDeviceID="42020142500002"
heatswap_work_alarm_Id="0425002001"
#######热交换故障告警
function heatswap_work_alarm_warn()
{
  	##################记录告警次数######################
	if [ ! -f "heatswap_work_alarm_alarm_count" ];then
			echo  "0"   >   heatswap_work_alarm_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "heatswap_work_alarm_open_time" ];then
			date +%s   >   heatswap_work_alarm_open_time
	fi
	
	if [ "$(cat heatswap_work_alarm_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################热交换故障告警########################
		if [ $(cat heatswap_work_alarm) -eq 1 ];then
			echo  "1"   >   heatswap_work_alarm_begin
			echo $((1+$(cat heatswap_work_alarm_alarm_count))) >  heatswap_work_alarm_alarm_count
			if [ $(cat heatswap_work_alarm_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  heatswap_work_alarm_serial_high_frequency
				insert_history   "$time"   "$heatswap_work_alarm_Id"      "$(cat heatswap_work_alarm)"   "$HeatSwapDeviceID"    "热交换故障告警"      "2"    "2"
				add_warning   "$(cat heatswap_work_alarm_serial_high_frequency)"    "$heatswap_work_alarm_Id"       "$FsuId_All"     "$HeatSwapDeviceID"     "$time"   "2"   "BEGIN"    "高频告警：热交换故障告警"
				echo "0"  >  heatswap_work_alarm_alarm_count   #########重新计数
				echo "1"  >  heatswap_work_alarm_close    ##########关闭告警
				date +%s  >  heatswap_work_alarm_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  heatswap_work_alarm_serial
				insert_history   "$time"   "$heatswap_work_alarm_Id"      "$(cat heatswap_work_alarm)"   "$HeatSwapDeviceID"    "热交换故障告警"      "2"    "2"
				add_warning   "$(cat heatswap_work_alarm_serial)"    "$heatswap_work_alarm_Id"       "$FsuId_All"     "$HeatSwapDeviceID"     "$time"   "2"   "BEGIN"    "热交换故障告警"
			fi	
		else
			if [ $(cat heatswap_work_alarm_begin) -eq 1 ];then
			   echo  "0"   >   heatswap_work_alarm_begin
			   add_warning   "$(cat heatswap_work_alarm_serial)"    "$heatswap_work_alarm_Id"       "$FsuId_All"     "$HeatSwapDeviceID"     "$time"   "2"   "END"    "热交换故障告警"
			fi
		fi

		if [ $(echo "$(cat heatswap_work_alarm_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  heatswap_work_alarm_alarm_count     #########重新计数
			date +%s  >  heatswap_work_alarm_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat heatswap_work_alarm_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  heatswap_work_alarm_close
			date +%s  >  heatswap_work_alarm_open_time       #########记录开始告警时间
			add_warning   "$(cat heatswap_work_alarm_serial_high_frequency)"    "$heatswap_work_alarm_Id"       "$FsuId_All"     "$HeatSwapDeviceID"     "$time"   "2"   "END"    "高频告警：热交换故障告警"
		fi
	fi
}


DoorGuardDeviceID="42020141700002"
guard_system_door_status_Id="0417005001" 
#######门磁开关状态
function guard_system_door_status_warn()
{
  	##################记录告警次数######################
	if [ ! -f "guard_system_door_status_alarm_count" ];then
			echo  "0"   >   guard_system_door_status_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "guard_system_door_status_open_time" ];then
			date +%s   >   guard_system_door_status_open_time
	fi
	
	if [ "$(cat guard_system_door_status_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat guard_system_door_status) -eq 1 ];then
			echo  "1"   >   guard_system_door_status_begin
			echo $((1+$(cat guard_system_door_status_alarm_count))) >  guard_system_door_status_alarm_count
			if [ $(cat guard_system_door_status_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  guard_system_door_status_serial_high_frequency
				insert_history   "$time"   "$guard_system_door_status_Id"      "$(cat guard_system_door_status)"   "$DoorGuardDeviceID"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat guard_system_door_status_serial_high_frequency)"    "$guard_system_door_status_Id"       "$FsuId_All"     "$DoorGuardDeviceID"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  guard_system_door_status_alarm_count   #########重新计数
				echo "1"  >  guard_system_door_status_close    ##########关闭告警
				date +%s  >  guard_system_door_status_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$guard_system_door_status_Id"      "$(cat guard_system_door_status)"   "$DoorGuardDeviceID"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  guard_system_door_status_serial			
				add_warning   "$(cat guard_system_door_status_serial)"    "$guard_system_door_status_Id"       "$FsuId_All"     "$DoorGuardDeviceID"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat guard_system_door_status_begin) -eq 1 ];then
			   echo  "0"   >   guard_system_door_status_begin
			   add_warning   "$(cat guard_system_door_status_serial)"    "$guard_system_door_status_Id"       "$FsuId_All"     "$DoorGuardDeviceID"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat guard_system_door_status_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  guard_system_door_status_alarm_count     #########重新计数
			date +%s  >  guard_system_door_status_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat guard_system_door_status_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  guard_system_door_status_close
			date +%s  >  guard_system_door_status_open_time       #########记录开始告警时间
			add_warning   "$(cat guard_system_door_status_serial_high_frequency)"    "$guard_system_door_status_Id"       "$FsuId_All"     "$DoorGuardDeviceID"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}


door_magnetic1_Id="0417005001"
door_magnetic1_deviceid="42020141850005"
#######门禁开关状态
function door_magnetic1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "door_magnetic1_alarm_count" ];then
			echo  "0"   >   door_magnetic1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "door_magnetic1_open_time" ];then
			date +%s   >   door_magnetic1_open_time
	fi
	
	if [ "$(cat door_magnetic1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat door_magnetic1) -eq 1 ];then
			echo  "1"   >   door_magnetic1_begin
			echo $((1+$(cat door_magnetic1_alarm_count))) >  door_magnetic1_alarm_count
			if [ $(cat door_magnetic1_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  door_magnetic1_serial_high_frequency
				insert_history   "$time"   "$door_magnetic1_Id"      "$(cat door_magnetic1)"   "$door_magnetic1_deviceid"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat door_magnetic1_serial_high_frequency)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  door_magnetic1_alarm_count   #########重新计数
				echo "1"  >  door_magnetic1_close    ##########关闭告警
				date +%s  >  door_magnetic1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$door_magnetic1_Id"      "$(cat door_magnetic1)"   "$door_magnetic1_deviceid"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  door_magnetic1_serial			
				add_warning   "$(cat door_magnetic1_serial)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat door_magnetic1_begin) -eq 1 ];then
			   echo  "0"   >   door_magnetic1_begin
			   add_warning   "$(cat door_magnetic1_serial)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat door_magnetic1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic1_alarm_count     #########重新计数
			date +%s  >  door_magnetic1_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat door_magnetic1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic1_close
			date +%s  >  door_magnetic1_open_time       #########记录开始告警时间
			add_warning   "$(cat door_magnetic1_serial_high_frequency)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}

door_magnetic1_Id="0417005001"
door_magnetic1_deviceid="42020141850005"
#######门禁开关状态
function door_magnetic1_warn()
{
  	##################记录告警次数######################
	if [ ! -f "door_magnetic1_alarm_count" ];then
			echo  "0"   >   door_magnetic1_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "door_magnetic1_open_time" ];then
			date +%s   >   door_magnetic1_open_time
	fi
	
	if [ "$(cat door_magnetic1_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat door_magnetic1) -eq 1 ];then
			echo  "1"   >   door_magnetic1_begin
			echo $((1+$(cat door_magnetic1_alarm_count))) >  door_magnetic1_alarm_count
			if [ $(cat door_magnetic1_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  door_magnetic1_serial_high_frequency
				insert_history   "$time"   "$door_magnetic1_Id"      "$(cat door_magnetic1)"   "$door_magnetic1_deviceid"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat door_magnetic1_serial_high_frequency)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  door_magnetic1_alarm_count   #########重新计数
				echo "1"  >  door_magnetic1_close    ##########关闭告警
				date +%s  >  door_magnetic1_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$door_magnetic1_Id"      "$(cat door_magnetic1)"   "$door_magnetic1_deviceid"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  door_magnetic1_serial			
				add_warning   "$(cat door_magnetic1_serial)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat door_magnetic1_begin) -eq 1 ];then
			   echo  "0"   >   door_magnetic1_begin
			   add_warning   "$(cat door_magnetic1_serial)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat door_magnetic1_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic1_alarm_count     #########重新计数
			date +%s  >  door_magnetic1_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat door_magnetic1_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic1_close
			date +%s  >  door_magnetic1_open_time       #########记录开始告警时间
			add_warning   "$(cat door_magnetic1_serial_high_frequency)"    "$door_magnetic1_Id"       "$FsuId_All"     "$door_magnetic1_deviceid"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}


door_magnetic2_Id="0417005001"
door_magnetic2_deviceid="42020141850006"
#######门禁开关状态
function door_magnetic2_warn()
{
  	##################记录告警次数######################
	if [ ! -f "door_magnetic2_alarm_count" ];then
			echo  "0"   >   door_magnetic2_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "door_magnetic2_open_time" ];then
			date +%s   >   door_magnetic2_open_time
	fi
	
	if [ "$(cat door_magnetic2_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat door_magnetic2) -eq 1 ];then
			echo  "1"   >   door_magnetic2_begin
			echo $((1+$(cat door_magnetic2_alarm_count))) >  door_magnetic2_alarm_count
			if [ $(cat door_magnetic2_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  door_magnetic2_serial_high_frequency
				insert_history   "$time"   "$door_magnetic2_Id"      "$(cat door_magnetic2)"   "$door_magnetic2_deviceid"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat door_magnetic2_serial_high_frequency)"    "$door_magnetic2_Id"       "$FsuId_All"     "$door_magnetic2_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  door_magnetic2_alarm_count   #########重新计数
				echo "1"  >  door_magnetic2_close    ##########关闭告警
				date +%s  >  door_magnetic2_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$door_magnetic2_Id"      "$(cat door_magnetic2)"   "$door_magnetic2_deviceid"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  door_magnetic2_serial			
				add_warning   "$(cat door_magnetic2_serial)"    "$door_magnetic2_Id"       "$FsuId_All"     "$door_magnetic2_deviceid"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat door_magnetic2_begin) -eq 1 ];then
			   echo  "0"   >   door_magnetic2_begin
			   add_warning   "$(cat door_magnetic2_serial)"    "$door_magnetic2_Id"       "$FsuId_All"     "$door_magnetic2_deviceid"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat door_magnetic2_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic2_alarm_count     #########重新计数
			date +%s  >  door_magnetic2_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat door_magnetic2_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic2_close
			date +%s  >  door_magnetic2_open_time       #########记录开始告警时间
			add_warning   "$(cat door_magnetic2_serial_high_frequency)"    "$door_magnetic2_Id"       "$FsuId_All"     "$door_magnetic2_deviceid"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}


door_magnetic3_Id="0417005001"
door_magnetic3_deviceid="42020141850007"
#######门禁开关状态
function door_magnetic3_warn()
{
  	##################记录告警次数######################
	if [ ! -f "door_magnetic3_alarm_count" ];then
			echo  "0"   >   door_magnetic3_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "door_magnetic3_open_time" ];then
			date +%s   >   door_magnetic3_open_time
	fi
	
	if [ "$(cat door_magnetic3_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat door_magnetic3) -eq 1 ];then
			echo  "1"   >   door_magnetic3_begin
			echo $((1+$(cat door_magnetic3_alarm_count))) >  door_magnetic3_alarm_count
			if [ $(cat door_magnetic3_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  door_magnetic3_serial_high_frequency
				insert_history   "$time"   "$door_magnetic3_Id"      "$(cat door_magnetic3)"   "$door_magnetic3_deviceid"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat door_magnetic3_serial_high_frequency)"    "$door_magnetic3_Id"       "$FsuId_All"     "$door_magnetic3_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  door_magnetic3_alarm_count   #########重新计数
				echo "1"  >  door_magnetic3_close    ##########关闭告警
				date +%s  >  door_magnetic3_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$door_magnetic3_Id"      "$(cat door_magnetic3)"   "$door_magnetic3_deviceid"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  door_magnetic3_serial			
				add_warning   "$(cat door_magnetic3_serial)"    "$door_magnetic3_Id"       "$FsuId_All"     "$door_magnetic3_deviceid"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat door_magnetic3_begin) -eq 1 ];then
			   echo  "0"   >   door_magnetic3_begin
			   add_warning   "$(cat door_magnetic3_serial)"    "$door_magnetic3_Id"       "$FsuId_All"     "$door_magnetic3_deviceid"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat door_magnetic3_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic3_alarm_count     #########重新计数
			date +%s  >  door_magnetic3_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat door_magnetic3_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic3_close
			date +%s  >  door_magnetic3_open_time       #########记录开始告警时间
			add_warning   "$(cat door_magnetic3_serial_high_frequency)"    "$door_magnetic3_Id"       "$FsuId_All"     "$door_magnetic3_deviceid"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}


door_magnetic4_Id="0417005001"
door_magnetic4_deviceid="42020141850008"
#######门禁开关状态
function door_magnetic4_warn()
{
  	##################记录告警次数######################
	if [ ! -f "door_magnetic4_alarm_count" ];then
			echo  "0"   >   door_magnetic4_alarm_count
	fi
	#################记录开始告警时间###################
	if [ ! -f "door_magnetic4_open_time" ];then
			date +%s   >   door_magnetic4_open_time
	fi
	
	if [ "$(cat door_magnetic4_close)" != "1" ];then   ##############在此判断屏蔽告警与否
		####################门禁检测到门被打开########################
		if [ $(cat door_magnetic4) -eq 1 ];then
			echo  "1"   >   door_magnetic4_begin
			echo $((1+$(cat door_magnetic4_alarm_count))) >  door_magnetic4_alarm_count
			if [ $(cat door_magnetic4_alarm_count) -gt 6 ];then  
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				cat Serial_No5  >  door_magnetic4_serial_high_frequency
				insert_history   "$time"   "$door_magnetic4_Id"      "$(cat door_magnetic4)"   "$door_magnetic4_deviceid"    "门禁检测到门被打开"      "2"    "3"
				add_warning   "$(cat door_magnetic4_serial_high_frequency)"    "$door_magnetic4_Id"       "$FsuId_All"     "$door_magnetic4_deviceid"     "$time"   "3"   "BEGIN"    "高频告警：门禁检测到门被打开"
				echo "0"  >  door_magnetic4_alarm_count   #########重新计数
				echo "1"  >  door_magnetic4_close    ##########关闭告警
				date +%s  >  door_magnetic4_close_time       #########记录关闭告警时间
			else
				echo $(($(cat Serial_No5)+1))  >  Serial_No5
				insert_history   "$time"   "$door_magnetic4_Id"      "$(cat door_magnetic4)"   "$door_magnetic4_deviceid"    "门禁检测到门被打开"      "2"    "3"
				cat Serial_No5  >  door_magnetic4_serial			
				add_warning   "$(cat door_magnetic4_serial)"    "$door_magnetic4_Id"       "$FsuId_All"     "$door_magnetic4_deviceid"     "$time"   "3"   "BEGIN"    "门禁检测到门被打开"
			fi	
		else
			if [ $(cat door_magnetic4_begin) -eq 1 ];then
			   echo  "0"   >   door_magnetic4_begin
			   add_warning   "$(cat door_magnetic4_serial)"    "$door_magnetic4_Id"       "$FsuId_All"     "$door_magnetic4_deviceid"     "$time"   "3"   "END"    "门禁检测到门被打开"
			fi
		fi

		if [ $(echo "$(cat door_magnetic4_open_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic4_alarm_count     #########重新计数
			date +%s  >  door_magnetic4_open_time    #########重新记录开始告警时间
		fi
		
	else
		if [ $(echo "$(cat door_magnetic4_close_time)-$(date +%s)" | bc) -gt  1800 ];then 
			echo "0"  >  door_magnetic4_close
			date +%s  >  door_magnetic4_open_time       #########记录开始告警时间
			add_warning   "$(cat door_magnetic4_serial_high_frequency)"    "$door_magnetic4_Id"       "$FsuId_All"     "$door_magnetic4_deviceid"     "$time"   "3"   "END"    "高频告警：门禁检测到门被打开"
		fi
	fi
}




############################################################################################
while [[ 1 ]];do  ###循环定时上告报警
###########################系统环境量获取############################################################
	if [ ! -f "last_time_warn_detect555" ];then
		date +%s  >  last_time_warn_detect555
	fi
	time=$(get_time)
	current_time=$(echo $time | date +%s)
	time_interval=$(echo "$current_time-$(cat last_time_warn_detect555)" | bc)
	echo $time_interval
	if [ $time_interval -lt 0 ];then
		date +%s  >  last_time_warn_detect555
	fi
	date +%s  >  Serial_No5
	echo $(($(cat Serial_No5)+1))  >  Serial_No5
	if [ $time_interval -ge 20 ];then 
	    date +%s  >  last_time_warn_detect555
		#######告警报文开头
		add_warning_head
		#######烟感告警
		io_smoke1_warn
		io_smoke2_warn
		io_smoke3_warn
		io_smoke4_warn

		#######水浸告警
		soak_resist1_warn
		soak_resist2_warn
		soak_resist3_warn
		soak_resist4_warn

		#######告警报文结尾
		add_warning_tail
		
		##cat Send_Alarm.xml  >>  Alarm.log
		##echo  "###################################"   >>   Alarm.log
		python   Send_Alarm_Client.py  &
		echo "One Circle Upload Alarm5 finished"
	fi
	###############################################################################################################

#############################################################################
	sleep 5
	
done

