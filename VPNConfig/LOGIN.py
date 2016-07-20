#coding: utf-8 -*-
"""
Created on Sta June 6 19:48:51 2015

@author: Li Kaiyang
"""

import os
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import sqlite3
con = sqlite3.connect('/home/pi/www/services/FSUINFO.db')
cursor = con.execute("select UserName,PaSCword,FsuId,FsuCode,SCIP from FSUINFO ")
UserName = ''
PaSCword = ''
FsuId = ''
FsuCode = ''
SCIP = ''
for row in cursor:
    UserName = row[0]
    PaSCword=row[1]
    FsuId=row[2]
    FsuCode=row[3]
    SCIP=row[4]
url = 'http://'+SCIP+':8080/services/SCService?wsdl'
url = 'http://'+SCIP+':8080/services/SCService?wsdl'
from suds.client import Client
from suds.xsd.doctor import ImportDoctor, Import


imp = Import('http://schemas.xmlsoap.org/soap/encoding/')
d = ImportDoctor(imp)
client = Client(url, doctor = d)


xml_Login = '''<?xml version="1.0" encoding="utf-8"?>
<Request>
  <PK_Type>
    <Name>LOGIN</Name>
    <Code>101</Code>
  </PK_Type>
  <Info>
    <UserName>cntower</UserName>
    <PaSCword>cntower</PaSCword>
    <FsuId/>
    <FsuCode/>
    <FsuIP/>
    <DeviceList/>
  </Info>
</Request>
'''

try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

root = ET.fromstring(xml_Login)
nodelist = root.findall('Info/PaSCword')
for node in nodelist:
    node.text = PaSCword

nodelist = root.findall('Info/UserName')
for node in nodelist:
    node.text = UserName

nodelist = root.findall('Info/FsuId')
for node in nodelist:
    node.text = FsuId

nodelist = root.findall('Info/FsuCode')
for node in nodelist:
    node.text = FsuCode

ipaddr = os.popen('sh /home/pi/LiKaiYang/getipaddr.sh').read().rstrip()
print ipaddr
nodelist = root.findall('Info/FsuIP')
for node in nodelist:
    node.text = ipaddr
con.close()

con = sqlite3.connect('/home/pi/www/services/history.db')
nodelist = root.findall('Info/DeviceList')
cursor = con.execute("select DISTINCT DeviceID from TSemaphore")
for row in cursor:
    if row[0][0:6]==FsuId[0:6]:
    	deviceInfo='<Device Id="'+row[0]+'" Code="'+row[0]+'"/>'
    	for node in nodelist:
        	node.append((ET.fromstring(deviceInfo)))
con.close()
xml_Login = ET.tostring(root, encoding='utf8', method='xml')
print xml_Login
result = client.service.invoke(xml_Login)
print result


