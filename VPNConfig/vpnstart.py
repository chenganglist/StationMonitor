#!/usr/bin/python
import os
import time
import subprocess
import sqlite3
#con = sqlite3.connect('/home/pi/www/services/FSUINFO.db')
#cursor = con.execute("select IPSECIP,IPSECUSER,IPSECPWD from FSUINFO ")
IPSECIP = ''
IPSECUSER = ''
IPSECPWD = ''
#for row in cursor:
#    IPSECIP = row[0]
#    IPSECUSER=row[1]
#    IPSECPWD=row[2]

#changeIPaddr='''lns = '''+IPSECIP
#os.system('''sed -i "86s:.*:'''+changeIPaddr+''':g" /etc/xl2tpd/xl2tpd.conf''')
#changeUsername='''name= '''+IPSECUSER
#os.system('''sed -i "91s:.*:'''+changeUsername+''':g" /etc/xl2tpd/xl2tpd.conf''')
#changeUserpwd=IPSECUSER+'''         *        "'''+IPSECPWD+'''"              *'''
#print '''sed -i "3s:.*:'''+changeUserpwd+''':g"/etc/ppp/chap-secrets'''
#os.system('''sed -i "3s:.*:'''+changeUserpwd+''':g" /etc/ppp/chap-secrets''')

import requests

#hostname ='121.48.175.198' #example
while 1:
	try:
		response = requests.get('http://www.baidu.com')
        	print response.text
		os.popen('/bin/bash /home/pi/LiKaiYang/vpnstart.sh').read().rstrip()
                ipaddr=os.popen('/bin/bash /home/pi/LiKaiYang/getipaddr.sh').read().rstrip()
		if ipaddr!='':
			break;
	except:
		print 'ERROR'
		os.system('/bin/bash /home/pi/LiKaiYang/killprogress.sh')
		subprocess.Popen('sudo wvdial',shell=True)
		time.sleep(60)
	#response = os.system("ping -c 1 " + hostname)
	#and then check the response...
	#response = os.system("nc -u -z -v 101.2.244.13 1701")
	#print response
	#if response == 0:
 	#	 break;
	#time.sleep(5)
	#print "sleeped"
#result = os.popen('/bin/bash /home/pi/LiKaiYang/vpnstart.sh').read().rstrip()
os.popen('/bin/bash /home/pi/www/services/changeip.sh').read().rstrip()
os.system("route add -net 172.17.0.0/16 ppp1")
os.system("route add -net 10.10.0.0/16 ppp1")
#os.system("python /home/pi/LiKaiYang/LOGIN.py")
#print result

	
