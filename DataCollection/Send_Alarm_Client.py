import sys
reload(sys)
sys.setdefaultencoding('utf-8')

doc = open('Send_Alarm.xml','r')

import sqlite3
con = sqlite3.connect('/home/pi/www/services/history.db')
cursor = con.execute("select SCIP from FSULOGININFO ")
SCIP = ''

for row in cursor:
    SCIP=row[0]

print SCIP
  
xml_string=doc.read()

if(xml_string.find('<SerialNo>')>0):
  from suds.client import Client
  url="http://"+SCIP+":8080/services/SCService?wsdl"
  client=Client(url)

  print "The response:\n\n"

  print client.service.invoke(xml_string)
    
  print "\n\n\n"


  


