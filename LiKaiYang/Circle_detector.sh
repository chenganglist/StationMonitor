#!/bin/bash
####################################################################################################################
time_count=0      ####计算读取次数
num_count=20  
decimal_temperature1_bool=1
decimal_humidity1_bool=1 
decimal_temperature2_bool=1
decimal_humidity2_bool=1 
io_smoke1_bool=1
io_smoke2_bool=1
infared1_bool=1
infared2_bool=1
door_magnetic1_bool=1

####################################################################################################################
while [[ 1 ]];do  ###循环定时读取数据
	((num_count++))  
	((time_count++))
	if [  $time_count  -ge  10000 ];then
		cp /usr/share/nginx/www/SoapServer/history.db /usr/share/nginx/www/SoapServer/history-bak.db 
		sql="delete from TSemaphore_history"
		echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
		time_count=0
	else
                echo $time_count
	fi
###########################系统环境量获取##########################################################################################
	arminfo=$(getcominfo.exe)
	arm=${arminfo:28:36}
	arm=$(echo $arm | tr a-z A-Z)        ###转换数据为16进制大写字符串
######################################################################################################################

######################################################################################################################	
	temperature=${arm:0:4}
	decimal_temperature1=$(echo "obase=10;ibase=16;"$temperature | bc)
	decimal_temperature1=$(echo "scale=4; $decimal_temperature1*0.1" | bc -l )	
	sql="update TSemaphore set MeasureVal=$decimal_temperature1 where ID='1230000001'  and DeviceID='000000000000' and Explaination='温度1' "
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 


	humidity=${arm:8:4}
	decimal_humidity1=$(echo "obase=10;ibase=16;"$humidity | bc)
	decimal_humidity1=$(echo "scale=4; $decimal_humidity1*0.1" | bc -l)
	sql="update TSemaphore set MeasureVal=$decimal_humidity1 where ID='1230000002'  and DeviceID='000000000000' and Explaination='湿度1' "
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	
	temperature=${arm:4:4}
	decimal_temperature2=$(echo "obase=10;ibase=16;"$temperature | bc)
	decimal_temperature2=$(echo "scale=4; $decimal_temperature2*0.1" | bc -l )
	sql="update TSemaphore set MeasureVal=$decimal_temperature2 where ID='1230000003'  and DeviceID='000000000000' and Explaination='温度2' "
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
	
	
	humidity=${arm:12:4}
	decimal_humidity2=$(echo "obase=10;ibase=16;"$humidity | bc)
	decimal_humidity2=$(echo "scale=4; $decimal_humidity2*0.1" | bc -l)
	sql="update TSemaphore set MeasureVal=$decimal_humidity2 where ID='1230000004'  and DeviceID='000000000000' and Explaination='湿度2' "
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
####################################################################################################################
	sleep 1
        
####################################################################################################################
	io_bytes=${arm:32:4}
	io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
	io_binary_num=${#io_binary}
	io_add_num=$[ 16 - $io_binary_num ]
	
	count=1
	while [ $count -le $io_add_num ]; do
	    io_binary="0""$io_binary"
	    count=$((count + 1))
	done
#####################################################################################################################

####################################################################################################################
io_smoke1=${io_binary:0:1}
io_smoke2=${io_binary:1:1}
io_smoke3=${io_binary:2:1}
io_smoke4=${io_binary:3:1}
io_smoke5=${io_binary:4:1}

sql="update TSemaphore set MeasureVal=$io_smoke1 where ID='1230000009' and DeviceID='000000000000' and Explaination='烟感1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$io_smoke2 where ID='1230000010' and DeviceID='000000000000' and Explaination='烟感2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$io_smoke3 where ID='1230000011' and DeviceID='000000000000' and Explaination='烟感3' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$io_smoke4 where ID='1230000012' and DeviceID='000000000000' and Explaination='烟感4' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$io_smoke5 where ID='1230000013' and DeviceID='000000000000' and Explaination='烟感5' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sleep 1
####################################################################################################################

#####################################################################################################################	
infared1=${io_binary:5:1}
infared2=${io_binary:6:1}

sql="update TSemaphore set MeasureVal=$infared1 where ID='1230000014' and DeviceID='000000000000' and Explaination='红外1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$infared2 where ID='1230000015' and DeviceID='000000000000' and Explaination='红外2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
#####################################################################################################################


#####################################################################################################################
door_magnetic1=${io_binary:8:1}
door_magnetic2=${io_binary:9:1}
door_magnetic3=${io_binary:10:1}
door_magnetic4=${io_binary:11:1}
door_magnetic5=${io_binary:12:1}

sql="update TSemaphore set MeasureVal=$door_magnetic1 where ID='1230000017' and DeviceID='000000000000' and Explaination='门磁1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_magnetic2 where ID='1230000018' and DeviceID='000000000000' and Explaination='门磁2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_magnetic3 where ID='1230000019' and DeviceID='000000000000' and Explaination='门磁3' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_magnetic4 where ID='1230000020' and DeviceID='000000000000' and Explaination='门磁4' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_magnetic5 where ID='1230000021' and DeviceID='000000000000' and Explaination='门磁5' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

#####################################################################################################################
sleep 1

#####################################################################################################################
burglar_resist1=${io_binary:13:1}
burglar_resist2=${io_binary:14:1}

sql="update TSemaphore set MeasureVal=$burglar_resist1 where ID='1230000022' and DeviceID='000000000000' and Explaination='外机防盗1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$burglar_resist2 where ID='1230000023' and DeviceID='000000000000' and Explaination='外机防盗2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

#####################################################################################################################


#####################################################################################################################
     #########################################################
io_bytes=${arm:36:4}
io_binary=$(echo "obase=2;ibase=16;"$io_bytes | bc)
io_binary_num=${#io_binary}
io_add_num=$[ 16 - $io_binary_num ]

count=1
while [ $count -le $io_add_num ]; do
	io_binary="0""$io_binary"
	count=$((count + 1))
done
     #########################################################
######################################################################################################################

######################################################################################################################
soak_resist1=${io_binary:0:1}
soak_resist2=${io_binary:1:1}
soak_resist3=${io_binary:2:1}
soak_resist4=${io_binary:3:1}
soak_resist5=${io_binary:4:1}

sql="update TSemaphore set MeasureVal=$soak_resist1 where ID='1230000025' and DeviceID='000000000000' and Explaination='水浸1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$soak_resist2 where ID='1230000026' and DeviceID='000000000000' and Explaination='水浸2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$soak_resist3 where ID='1230000027' and DeviceID='000000000000' and Explaination='水浸3' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$soak_resist4 where ID='1230000028' and DeviceID='000000000000' and Explaination='水浸4' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$soak_resist5 where ID='1230000029' and DeviceID='000000000000' and Explaination='水浸5' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
######################################################################################################################
sleep 1

#####################################################################################################################
door_shake1=${io_binary:5:1}
door_shake2=${io_binary:6:1}
door_shake3=${io_binary:7:1}

sql="update TSemaphore set MeasureVal=$door_shake1 where ID='1230000030' and DeviceID='000000000000' and Explaination='门震动1' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_shake2 where ID='1230000031' and DeviceID='000000000000' and Explaination='门震动2' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

sql="update TSemaphore set MeasureVal=$door_shake3 where ID='1230000032' and DeviceID='000000000000' and Explaination='门震动3' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
######################################################################################################################

#####################################################################################################################
light_status=${io_binary:8:1}

sql="update TSemaphore set MeasureVal=$light_status where ID='1230000033' and DeviceID='000000000000' and Explaination='灯状态' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
#####################################################################################################################
sleep 1

######################################################################################################################
reset_status=${io_binary:9:1}

sql="update TSemaphore set MeasureVal=$reset_status where ID='1230000034' and DeviceID='000000000000' and Explaination='复位状态' "
echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
#####################################################################################################################

time=$(date +%Y-%m-%d%t%T)
###############################################################################################################
sleep 6
#/usr/share/nginx/www/SoapServer/elec_meter.sh  $num_count
###############################################################################################################
#######################################################################################################################
##########################################################
if [  $num_count  -ge  5 ];then
	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000001','000000000000','$decimal_temperature1','温度1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000002','000000000000','$decimal_humidity1','湿度1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000003','000000000000','$decimal_temperature2','温度2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000004','000000000000','$decimal_humidity2','湿度2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000009','000000000000','$io_smoke1','烟感1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000010','000000000000','$io_smoke2','烟感2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000011','000000000000','$io_smoke3','烟感3')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000012','000000000000','$io_smoke4','烟感4')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000013','000000000000','$io_smoke5','烟感5')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000014','000000000000','$infared1','红外1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000015','000000000000','$infared2','红外2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000017','000000000000','$door_magnetic1','门磁1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000018','000000000000','$door_magnetic2','门磁2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000019','000000000000','$door_magnetic3','门磁3')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000020','000000000000','$door_magnetic4','门磁4')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000021','000000000000','$door_magnetic5','门磁5')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000022','000000000000','$burglar_resist1','外机防盗1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000023','000000000000','$burglar_resist2','外机防盗2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000025','000000000000','$soak_resist1','水浸1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000026','000000000000','$soak_resist2','水浸2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
	
	sleep 1

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000027','000000000000','$soak_resist3','水浸3')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000028','000000000000','$soak_resist4','水浸4')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000029','000000000000','$soak_resist5','水浸5')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000030','000000000000','$door_shake1','门震动1')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000031','000000000000','$door_shake2','门震动2')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000032','000000000000','$door_shake3','门震动3')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000033','000000000000','$light_status','灯状态')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000034','000000000000','$reset_status','复位状态')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
	
fi

	#########################		
########################################################################################################################


###############################warning#####################warning#############################################
#####warning####################################################warning########################################
#####warning####################################################warning########################################
Serial_No=$(date +%s)
##########################################

sql="select Threshold from TThreshold where ID='1230000001' and DeviceID='000000000000'"
temperature_set1=$(echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db )

sql="select Threshold from TThreshold where ID='1230000002' and DeviceID='000000000000'"
humidity_set1=$(echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db )

sql="select Threshold from TThreshold where ID='1230000003' and DeviceID='000000000000'"
temperature_set2=$(echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db )

sql="select Threshold from TThreshold where ID='1230000004' and DeviceID='000000000000'"
humidity_set2=$(echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db )

###########################################
echo     "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<Request>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<PK_Type>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<Name>SEND_ALARM</Name>"   >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<Code>501</Code>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<Info>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<Values>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "<TAlarmList>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml

if [ $(echo "$decimal_temperature1 > $temperature_set1"|bc) -eq 1 ];then
	((Serial_No=Serial_No+1))
	decimal_temperature1_bool=0
	echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<ID>1230000003</ID>"   >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmFlag>开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmDesc>温度过高($decimal_temperature1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
    if [  $decimal_temperature1_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
		echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<ID>1230000003</ID>"   >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmFlag>结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmDesc>温度过高($decimal_temperature1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml   
		decimal_temperature1_bool=1
	fi 
fi


if [ $(echo "$decimal_humidity1 > $humidity_set1"|bc) -eq 1 ];then
	((Serial_No=Serial_No+1))
	decimal_humidity1_bool=0
	echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<ID>1230000002</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmFlag>报警开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "<AlarmDesc>湿度过高($decimal_humidity1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
	echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $decimal_humidity1_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
		echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<ID>1230000002</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmDesc>湿度过高($decimal_humidity1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml  
		decimal_humidity1_bool=1
	fi      		
fi


if [ $(echo "$decimal_temperature2 > $temperature_set2"|bc) -eq 1 ];then
	    ((Serial_No=Serial_No+1))
	    decimal_temperature2_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000003</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>温度过高($decimal_temperature2)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $decimal_temperature2_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
		echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<ID>1230000003</ID>"   >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmFlag>结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmDesc>温度过高($decimal_temperature1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml   
		decimal_temperature2_bool=1
	fi        		
fi


if [ $(echo "$decimal_humidity2 > $humidity_set2"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		decimal_humidity2_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000004</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>湿度过高($decimal_humidity2)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $decimal_humidity2_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
		echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<ID>1230000002</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "<AlarmDesc>湿度过高($decimal_humidity1)</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		echo     "</TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml  
		decimal_humidity2_bool=1
	fi      		   		
fi


if [ $(echo "$io_smoke1 > 0"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		io_smoke1_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000009</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>烟感检测到有烟</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $io_smoke1_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000009</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>烟感检测到有烟</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		io_smoke1_bool=1
	fi      		   	       		
fi

if [ $(echo "$io_smoke2 > 0"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		io_smoke2_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000010</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>烟感检测到有烟</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $io_smoke2_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000009</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>烟感检测到有烟</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		io_smoke2_bool=1
	fi      		   	             		
fi


if [ $(echo "$infared1 > 0"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		infared1_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000014</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>红外检测到有人</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $infared1_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000014</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>红外检测到有人</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		infared1_bool=1
	fi      		   	             				  		
fi


if [ $(echo "$infared2 > 0"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		infared2_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000015</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>红外检测到有人</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $infared2_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000014</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>红外检测到有人</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		infared2_bool=1
	fi      		   		
fi

if [ $(echo "$door_magnetic1 > 0"|bc) -eq 1 ];then
        ((Serial_No=Serial_No+1))
		door_magnetic1_bool=0
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000016</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>开始</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>门磁检测到门被打开</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
else
	if [  $door_magnetic1_bool  -eq  0 ];then
		((Serial_No=Serial_No+1))
        echo     "<TAlarm>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<SerialNo>$Serial_No</SerialNo>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<ID>1230000016</ID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<FSUID>10024</FSUID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<DeviceID>000000000000</DeviceID>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmTime>$time</AlarmTime>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmLevel>二级</AlarmLevel>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmFlag>报警结束</AlarmFlag>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "<AlarmDesc>门磁检测到门已关上</AlarmDesc>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
        echo     "</TAlarm>" >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
		door_magnetic1_bool=1
	fi      		   		  		
fi


echo     "</TAlarmList>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "</Values>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "</Info>"  >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml
echo     "</Request>"   >>  /usr/share/nginx/www/SoapServer/SEND_ALARM.xml;
#python   /usr/share/nginx/www/SoapServer/Send_Alarm_Client.py;
cat /usr/share/nginx/www/SoapServer/SEND_ALARM.xml >>  /usr/share/nginx/www/SoapServer/Alarm.log

#####warning####################################################warning########################################
#####warning####################################################warning########################################
#####################################################################################################################
elec_meter_all=$(elec_meter_all.exe)
elec_meter_all=$(echo $elec_meter_all | tr a-z A-Z)
#####################################################################################################################

###################################################################################################################
A_phase_voltage=${elec_meter_all:0:4}
decimal_A_phase_voltage1=$(echo "obase=10;ibase=16;"$A_phase_voltage | bc)
decimal_A_phase_voltage1=$(echo "scale=4; $decimal_A_phase_voltage1/10" | bc -l )	
#######echo $decimal_A_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_voltage1 where ID='1230000001' and DeviceID='000000000001' and Explaination='A相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


B_phase_voltage=${elec_meter_all:4:4}
decimal_B_phase_voltage1=$(echo "obase=10;ibase=16;"$B_phase_voltage | bc)
decimal_B_phase_voltage1=$(echo "scale=4; $decimal_B_phase_voltage1/10" | bc -l)
#######echo $decimal_B_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_voltage1 where ID='1230000002' and DeviceID='000000000001' and Explaination='B相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

C_phase_voltage=${elec_meter_all:8:4}
decimal_C_phase_voltage1=$(echo "obase=10;ibase=16;"$C_phase_voltage | bc)
decimal_C_phase_voltage1=$(echo "scale=4; $decimal_C_phase_voltage1/10" | bc -l)
#######echo $decimal_C_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_voltage1  where ID='1230000003' and DeviceID='000000000001' and Explaination='C相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

AB_phase_voltage=${elec_meter_all:12:4}
decimal_AB_phase_voltage1=$(echo "obase=10;ibase=16;"$AB_phase_voltage | bc)
decimal_AB_phase_voltage1=$(echo "scale=4; $decimal_AB_phase_voltage1/10" | bc -l)
#######echo $decimal_AB_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_AB_phase_voltage1  where ID='1230000004' and DeviceID='000000000001' and Explaination='AB相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 
sleep 1

CA_phase_voltage=${elec_meter_all:16:4}
decimal_CA_phase_voltage1=$(echo "obase=10;ibase=16;"$CA_phase_voltage | bc)
decimal_CA_phase_voltage1=$(echo "scale=4; $decimal_CA_phase_voltage1/10" | bc -l)
#######echo $decimal_CA_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_CA_phase_voltage1  where ID='1230000005' and DeviceID='000000000001' and Explaination='CA相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

BC_phase_voltage=${elec_meter_all:20:4}
decimal_BC_phase_voltage1=$(echo "obase=10;ibase=16;"$BC_phase_voltage | bc)
decimal_BC_phase_voltage1=$(echo "scale=4; $decimal_BC_phase_voltage1/10" | bc -l)
#######echo $decimal_BC_phase_voltage1
sql="update TSemaphore set MeasureVal=$decimal_BC_phase_voltage1  where ID='1230000006' and DeviceID='000000000001' and Explaination='BC相电压' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

A_phase_current=${elec_meter_all:24:4}
decimal_A_phase_current1=$(echo "obase=10;ibase=16;"$A_phase_current | bc)
decimal_A_phase_current1=$(echo "scale=4; $decimal_A_phase_current1/1000" | bc -l)
#######echo $decimal_A_phase_current1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_current1  where ID='1230000007' and DeviceID='000000000001' and Explaination='A相电流' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

B_phase_current=${elec_meter_all:28:4}
decimal_B_phase_current1=$(echo "obase=10;ibase=16;"$B_phase_current | bc)
decimal_B_phase_current1=$(echo "scale=4; $decimal_B_phase_current1/1000" | bc -l)
#######echo $decimal_B_phase_current1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_current1  where ID='1230000008' and DeviceID='000000000001' and Explaination='B相电流' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

C_phase_current=${elec_meter_all:32:4}
decimal_C_phase_current1=$(echo "obase=10;ibase=16;"$C_phase_current | bc)
decimal_C_phase_current1=$(echo "scale=4; $decimal_C_phase_current1/1000" | bc -l)
#######echo $decimal_C_phase_current1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_current1  where ID='1230000009' and DeviceID='000000000001' and Explaination='C相电流' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

sleep 1
##############################################################################################################


A_phase_active_power=${elec_meter_all:40:4}
decimal_A_phase_active_power1=$(echo "obase=10;ibase=16;"$A_phase_active_power | bc)
decimal_A_phase_active_power1=$(echo "scale=4; $decimal_A_phase_active_power1/10" | bc -l)
#######echo $decimal_A_phase_active_power1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_active_power1  where ID='1230000010' and DeviceID='000000000001' and Explaination='A相有功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

B_phase_active_power=${elec_meter_all:44:4}
decimal_B_phase_active_power1=$(echo "obase=10;ibase=16;"$B_phase_active_power | bc)
decimal_B_phase_active_power1=$(echo "scale=4; $decimal_B_phase_active_power1/10" | bc -l)
#######echo $decimal_B_phase_active_power1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_active_power1  where ID='1230000011' and DeviceID='000000000001' and Explaination='B相有功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


C_phase_active_power=${elec_meter_all:48:4}
decimal_C_phase_active_power1=$(echo "obase=10;ibase=16;"$C_phase_active_power | bc)
decimal_C_phase_active_power1=$(echo "scale=4; $decimal_C_phase_active_power1/10" | bc -l)
#######echo $decimal_C_phase_active_power1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_active_power1  where ID='1230000012' and DeviceID='000000000001' and Explaination='C相有功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


Total_active_power=${elec_meter_all:52:4}
decimal_Total_active_power1=$(echo "obase=10;ibase=16;"$Total_active_power | bc)
decimal_Total_active_power1=$(echo "scale=4; $decimal_Total_active_power1/10" | bc -l)
#######echo $decimal_Total_active_power1
sql="update TSemaphore set MeasureVal=$decimal_Total_active_power1  where ID='1230000013' and DeviceID='000000000001' and Explaination='总有功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


A_phase_reactive_power=${elec_meter_all:56:4}
decimal_A_phase_reactive_power1=$(echo "obase=10;ibase=16;"$A_phase_reactive_power | bc)
decimal_A_phase_reactive_power1=$(echo "scale=4; $decimal_A_phase_reactive_power1/10" | bc -l)
#######echo $decimal_A_phase_reactive_power1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_reactive_power1  where ID='1230000014' and DeviceID='000000000001' and Explaination='A相无功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


B_phase_reactive_power=${elec_meter_all:60:4}
decimal_B_phase_reactive_power1=$(echo "obase=10;ibase=16;"$B_phase_reactive_power | bc)
decimal_B_phase_reactive_power1=$(echo "scale=4; $decimal_B_phase_reactive_power1/10" | bc -l)
#######echo $decimal_B_phase_reactive_power1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_reactive_power1  where ID='1230000015' and DeviceID='000000000001' and Explaination='B相无功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


C_phase_reactive_power=${elec_meter_all:64:4}
decimal_C_phase_reactive_power1=$(echo "obase=10;ibase=16;"$C_phase_reactive_power | bc)
decimal_C_phase_reactive_power1=$(echo "scale=4; $decimal_C_phase_reactive_power1/10" | bc -l)
#######echo $decimal_C_phase_reactive_power1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_reactive_power1  where ID='1230000016' and DeviceID='000000000001' and Explaination='C相无功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

Total_reactive_power=${elec_meter_all:68:4}
decimal_Total_reactive_power1=$(echo "obase=10;ibase=16;"$Total_reactive_power | bc)
decimal_Total_reactive_power1=$(echo "scale=4; $decimal_Total_reactive_power1/10" | bc -l)
#######echo $decimal_Total_reactive_power1
sql="update TSemaphore set MeasureVal=$decimal_Total_reactive_power1  where ID='1230000017' and DeviceID='000000000001' and Explaination='总无功功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 
sleep 1

A_phase_apparent_power=${elec_meter_all:72:4}
decimal_A_phase_apparent_power1=$(echo "obase=10;ibase=16;"$A_phase_apparent_power | bc)
decimal_A_phase_apparent_power1=$(echo "scale=4; $decimal_A_phase_apparent_power1/10" | bc -l)
#######echo $decimal_A_phase_apparent_power1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_apparent_power1  where ID='1230000018' and DeviceID='000000000001' and Explaination='A相视在功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

B_phase_apparent_power=${elec_meter_all:76:4}
decimal_B_phase_apparent_power1=$(echo "obase=10;ibase=16;"$B_phase_apparent_power | bc)
decimal_B_phase_apparent_power1=$(echo "scale=4; $decimal_B_phase_apparent_power1/10" | bc -l)
#######echo $decimal_B_phase_apparent_power1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_apparent_power1  where ID='1230000019' and DeviceID='000000000001' and Explaination='B相视在功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

C_phase_apparent_power=${elec_meter_all:80:4}
decimal_C_phase_apparent_power1=$(echo "obase=10;ibase=16;"$C_phase_apparent_power | bc)
decimal_C_phase_apparent_power1=$(echo "scale=4; $decimal_C_phase_apparent_power1/10" | bc -l)
#######echo $decimal_C_phase_apparent_power1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_apparent_power1  where ID='1230000020' and DeviceID='000000000001' and Explaination='C相视在功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

Total_apparent_power=${elec_meter_all:84:4}
decimal_Total_apparent_power1=$(echo "obase=10;ibase=16;"$Total_apparent_power | bc)
decimal_Total_apparent_power1=$(echo "scale=4; $decimal_Total_apparent_power1/10" | bc -l)
#######echo $decimal_Total_apparent_power1
sql="update TSemaphore set MeasureVal=$decimal_Total_apparent_power1  where ID='1230000021' and DeviceID='000000000001' and Explaination='总视在功率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

A_phase_power_factor=${elec_meter_all:88:4}
decimal_A_phase_power_factor1=$(echo "obase=10;ibase=16;"$A_phase_power_factor | bc)
decimal_A_phase_power_factor1=$(echo "scale=4; $decimal_A_phase_power_factor1/1000" | bc -l)
#######echo $decimal_A_phase_power_factor1
sql="update TSemaphore set MeasureVal=$decimal_A_phase_power_factor1  where ID='1230000022' and DeviceID='000000000001' and Explaination='A相功率因素' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

B_phase_power_factor=${elec_meter_all:92:4}
decimal_B_phase_power_factor1=$(echo "obase=10;ibase=16;"$B_phase_power_factor | bc)
decimal_B_phase_power_factor1=$(echo "scale=4; $decimal_B_phase_power_factor1/1000" | bc -l)
#######echo $decimal_B_phase_power_factor1
sql="update TSemaphore set MeasureVal=$decimal_B_phase_power_factor1  where ID='1230000023' and DeviceID='000000000001' and Explaination='B相功率因素' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

C_phase_power_factor=${elec_meter_all:96:4}
decimal_C_phase_power_factor1=$(echo "obase=10;ibase=16;"$C_phase_power_factor | bc)
decimal_C_phase_power_factor1=$(echo "scale=4; $decimal_C_phase_power_factor1/1000" | bc -l)
#######echo $decimal_C_phase_power_factor1
sql="update TSemaphore set MeasureVal=$decimal_C_phase_power_factor1  where ID='1230000024' and DeviceID='000000000001' and Explaination='C相功率因素' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

Total_power_factor=${elec_meter_all:100:4}
decimal_Total_power_factor1=$(echo "obase=10;ibase=16;"$Total_power_factor | bc)
decimal_Total_power_factor1=$(echo "scale=4; $decimal_Total_power_factor1/1000" | bc -l)
#######echo $decimal_Total_power_factor1
sql="update TSemaphore set MeasureVal=$decimal_Total_power_factor1  where ID='1230000025' and DeviceID='000000000001' and Explaination='总功率因素' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 

frequency=${elec_meter_all:104:4}
decimal_frequency1=$(echo "obase=10;ibase=16;"$frequency | bc)
decimal_frequency1=$(echo "scale=4; $decimal_frequency1/100" | bc -l)
#######echo $decimal_frequency1
sql="update TSemaphore set MeasureVal=$decimal_frequency1 where ID='1230000026' and DeviceID='000000000001' and Explaination='频率' "
echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 


#sign=${elec_meter_all:36:4}
#sign1=$(echo "obase=10;ibase=16;"$C_phase_current | bc)
#decimal_sign1=$(echo "scale=4; $sign1" | bc -l)
#sql="update TSemaphore set MeasureVal=$decimal_sign1  where ID='1230000027' and DeviceID='000000000001' and Explaination='功率因素符号位' "
#echo "$sql;" | sqlite3 /usr/share/nginx/www/SoapServer/history.db 
sleep 1

##############################################################
if [  $num_count  -ge  5 ];then
	time=$(date +%Y-%m-%d%t%T)

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000001','000000000001','$decimal_A_phase_voltage1','A相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000002','000000000001','$decimal_B_phase_voltage1','B相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000003','000000000001','$decimal_C_phase_voltage1','C相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000004','000000000001','$decimal_AB_phase_voltage1','AB相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000005','000000000001','$decimal_CA_phase_voltage1','CA相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000006','000000000001','$decimal_BC_phase_voltage1','BC相电压')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
	
	sleep 1

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000007','000000000001','$decimal_A_phase_current1','A相电流')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000008','000000000001','$decimal_B_phase_current1','B相电流')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000009','000000000001','$decimal_C_phase_current1','C相电流')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000010','000000000001','$decimal_A_phase_active_power1','A相有功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000011','000000000001','$decimal_B_phase_active_power1','B相有功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000012','000000000001','$decimal_C_phase_active_power1','C相有功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000013','000000000001','$decimal_Total_active_power1','总有功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000014','000000000001','$decimal_A_phase_reactive_power1','A相无功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000015','000000000001','$decimal_B_phase_reactive_power1','B相无功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000016','000000000001','$decimal_C_phase_reactive_power1','C相无功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000017','000000000001','$decimal_Total_reactive_power1','总无功功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000018','000000000001','$decimal_A_phase_apparent_power1','A相视在功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000019','000000000001','$decimal_B_phase_apparent_power1','B相视在功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000020','000000000001','$decimal_C_phase_apparent_power1','C相视在功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000021','000000000001','$decimal_Total_apparent_power1','总视在功率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000022','000000000001','$decimal_A_phase_power_factor1','A相功率因素')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time , ID ,DeviceID , MeasureVal , Explain) values ('$time' ,'1230000023','000000000001','$decimal_B_phase_power_factor1','B相功率因素')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000024','000000000001','$decimal_C_phase_power_factor1','C相功率因素')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000024','000000000001','$decimal_Total_power_factor1','总功率因素')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000024','000000000001','$decimal_frequency1','频率')"
	echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 
	
	num_count=0
fi

#sql="insert into TSemaphore_history (Time ,ID ,DeviceID , MeasureVal , Explain) values ('$time','1230000024','000000000001','$decimal_sign1','功率因素符号位')"
#echo  "$sql;"  |  sqlite3  /usr/share/nginx/www/SoapServer/history.db 

	sleep 5
	echo "One Circle finished"

done
