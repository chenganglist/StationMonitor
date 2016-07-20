import commands


#from xml.etree import ElementTree 

from suds.client import sys
from suds.client import Client

from xml.etree.ElementTree import ElementTree,Element  


#DOMTree = xml.dom.minidom.parse("FSUInfo.xml")



def read_xml(in_path):  

    tree = ElementTree()  

    tree.parse(in_path)  

    return tree



def find_nodes(tree, path):  

    return tree.findall(path)



def write_xml(tree, out_path):  

    tree.write(out_path, encoding="utf-8",xml_declaration=True)  





tree = read_xml("LOGIN.xml")  

nodelist = tree.findall('Info/FSUIP')
(status,ipaddr)=commands.getstatusoutput("./getipaddr.sh")
for node in nodelist:

    node.text = ipaddr

print nodelist[0].text

write_xml(tree, "test1.xml") 
#tree.write("out.txt",method="text",encoding="utf-8")
url = "http://192.168.0.101:3343/SCService.asmx"

client = Client(url)

s='gsghsfhs'

print s
f = open('test1.xml','r')
xml_string = f.read()
print xml_string
#print tree.tostringlist(root,encoding="utf8",method="xml")
print client.service.invoke(xml_string)
