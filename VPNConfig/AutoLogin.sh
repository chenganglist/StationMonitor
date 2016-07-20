#!/bin/bash
sql="update COM_STATUS set SC_STATUS=0 where ID=1"
echo  "$sql;"  |  sqlite3  /home/pi/www/services/COM_STATUS.db
python /home/pi/LiKaiYang/AutoLogin.py
