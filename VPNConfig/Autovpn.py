#!/usr/bin/python
import os
import time
import subprocess

subprocess.Popen('sudo wvdial',shell=True)
time.sleep(10)
while 1:
	result = os.popen('/bin/bash /home/pi/LiKaiYang/getipaddr.sh').read().rstrip()
	print result
	if result=='':
		os.system("python /home/pi/LiKaiYang/vpnstart.py")


        result = os.popen('/bin/bash /home/pi/LiKaiYang/getppp0addr.sh').read().rstrip()
        print result
        if result=='':
                os.system("python /home/pi/LiKaiYang/vpnstart.py")

	time.sleep(30)



