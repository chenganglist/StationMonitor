import xml.dom.minidom

doc = open('/usr/share/nginx/www/SoapServer/SEND_ALARM.xml','r')
xml_string=doc.read()

if(xml_string.find('<SerialNo>')>0):
  #print xml_string
  from suds.client import Client
  url="http://192.168.1.110/WebService1.asmx?wsdl"
  client=Client(url)

  print "\n\nThe result:\n\n"

  print client.service.SendAlarm(xml_string)
    
  print "\n\n\n"


  


