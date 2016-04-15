_author__ = 'Administrator'
import csv
reader = csv.reader(open('/home/pi/LiKaiYang/_init_list.csv'))
SCIP=''
for line in reader:
    if line[0]=='SCIP':
        SCIP=line[1]

import sqlite3
con = sqlite3.connect('/home/pi/www/services/FSUINFO.db')
con.execute('''update FSUINFO set SCIP="'''+SCIP+'''" where FsuIP="172.16.1.1"''')
con.commit()
cursor = con.execute("select SCIP from FSUINFO")
for row in cursor:
     SCIP = row[0]
print  SCIP
con.close()

