import os
import re
import csv
def copy(filePath):
    fileName=""
    try:
 #       filePath="/media/lky/disk"
        mountRes=os.popen('cd '+filePath+' \n ls').read().rstrip()
        #mountRes.index('update.csv')
        #print mountRes
        
        results=re.findall(r'update.csv', mountRes, re.M | re.S)
         
        out=open("/home/pi/updateFile/version.txt","rw+") 
        nowVersion=out.read()
        out.seek(0)
        #out.close()
        #out.close() 
        #in=open('/project/version.txt','w')
        #csvfile = file('update.csv', 'rb')
        updateVersion="";
        if len(results)!=0:
        	print results[0]
        	csvfile=file(filePath+'/update.csv','rw')
        	reader = csv.reader(csvfile)
        	flag=1
        	
        	for line in reader:
        		print flag
        		if flag==1:
        			flag=flag+1;		
        			if line[1]>nowVersion:
                                       print line[1]
                                       updateVersion=line[1]
        			else:
        				return "You have the highest version!"
        				break;
        			continue
        		fileName=line[1];
        		cpResult=os.popen('sudo cp '+filePath+'/'+ line[0] +" " +line[1]).read().rstrip()
        		print('cp '+ line[0] +" " +line[1])
        	out.write(updateVersion)
        	out.close()
        return "Update success! "
    except Exception, e:
        print e
        return "Update "+ fileName+" error!"
    
  


#mountRes.index('update.csv')

