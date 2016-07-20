/usr/bin/wvdial &
/home/pi/PIC/camera.sh &
/home/pi/DataCollection/Update_Info.sh /dev/ttyUSB0 &
/home/pi/DataCollection/Update_Env.sh /dev/ttyUSB1 & 
/home/pi/DataCollection/Update_Database.sh &
/home/pi/DataCollection/Upload_Alarm_1.sh &
/home/pi/DataCollection/Upload_Alarm_2.sh &
/home/pi/DataCollection/Upload_Alarm_3.sh &
/home/pi/DataCollection/Upload_Alarm_4.sh &
