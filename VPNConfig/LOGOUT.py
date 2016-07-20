f = open('LOGOUT.xml','r')
xml_string=f.read()
print xml_string
from suds.client import Client


url="http://192.168.1.110/WebService1.asmx?wsdl"



client=Client(url)



print client.service.SendLogout(xml_string)
