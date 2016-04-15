#! /bin/bash
cd /home/pi/PIC
while [[ 1 ]];do
        result=$(ls |wc -l)
        if [ $result -gt 100 ];then
           rm *.jpg
	else
           python /home/pi/PIC/GrabImage.py
	   echo "one Image grabed"
        fi
        sleep 60
done
