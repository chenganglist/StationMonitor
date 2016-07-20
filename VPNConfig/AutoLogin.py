__author__ = 'Li Kaiyang'
import requests
import sqlite3
import os
import time
import re
while 1:
    try:
	con = sqlite3.connect('/home/pi/www/services/FSUINFO.db')
        cursor = con.execute("select SCIP from FSUINFO")
        SCIP = ''
        for row in cursor:
            SCIP = row[0]
	con.close()
        response = requests.get('http://'+SCIP+':8080/services/SCService?wsdl')
        response = requests.get('http://'+SCIP+':8080/services/SCService?wsdl')
	print response.text
	con = sqlite3.connect('/home/pi/www/services/COM_STATUS.db')
        cursor = con.execute("select SC_STATUS from COM_STATUS")
        SC_STATUS=''
        for row in cursor:
            SC_STATUS = row[0]
	print SC_STATUS
	m=re.findall(r"404",response.text);
	
        if SC_STATUS==0:
            con.execute("update COM_STATUS set SC_STATUS=1 where ID=1")
	    con.commit()
	    print 'YES1'
            os.system("python /home/pi/LiKaiYang/LOGIN.py")
	    print 'YES2'
	con.close()
	
    except:
	con = sqlite3.connect('/home/pi/www/services/COM_STATUS.db')
        con.execute("update COM_STATUS set SC_STATUS=0 where ID=1")
	con.commit()
	print 'ERROR'
        con.close()
	con = sqlite3.connect('/home/pi/www/services/COM_STATUS.db')
        cursor = con.execute("select SC_STATUS from COM_STATUS where ID=1")
        SC_STATUS=''
        for row in cursor:
            SC_STATUS = row[0]
        print SC_STATUS

	print 'ERROR'
    time.sleep(5)



