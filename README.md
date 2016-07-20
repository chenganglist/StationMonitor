##项目目录结构
###一、数据采集、存储和告警脚本--DataCollection目录
####1、所有脚本文件说明    

	getcominfo.sh   ----   获取采集板上的传感器信息---比如红外、温度、湿度、门磁状态等
	air_condition.sh  ---  空调信息采集         
	simpleget.sh  ---  获取所有传感信息的调试文件       
     
	DongLi_switch_battery.sh   ---  开关电源信息采集
	switch_battery.sh     ---  开关电源信息采集
   
	door.sh   ---  门禁信息采集                   
	heatswap.sh   --- 热交换设备信息采集   
	ele_meter.sh  --- 电表信息采集             
   
	Emerson_switch_battery.sh  ---- Emerson开关电源信息采集
	ZhongDa_switch_battery.sh  ---- ZhongDa开关电源信息采集        
	zhongheng_switch_battery.sh  ---- zhongheng开关电源信息采集                  
	ZhongXing_switch_battery.sh  ---- ZhongXing开关电源信息采集     
	HuaWei_switch_battery.sh  ---- HuaWei开关电源信息采集   
	ZhuJiang_switch_battery.sh  ---- ZhuJiang开关电源信息采集


	Update_Info.sh  ---  定时更新智能传感器文件数据
	Update_Env.sh  ---采集板 -----------定时更新数据采集板上的传感器文件数据    
	Update_Database.sh  --- 定时读取传感器文件数据，写入到数据库   

	Upload_Alarm.sh    --- 定时生成告警信息到Send_Alarm.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息   
 	Upload_Alarm_1.sh  --- 定时生成告警信息到Send_Alarm_1.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息 
	Upload_Alarm_2.sh  --- 定时生成告警信息到Send_Alarm_2.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息 
	Upload_Alarm_3.sh  --- 定时生成告警信息到Send_Alarm_3.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息
	Upload_Alarm_4.sh  --- 定时生成告警信息到Send_Alarm_4.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息 
	Upload_Alarm_5.sh  --- 定时生成告警信息到Send_Alarm_5.xml，并读取告警信息，通过Send_Alarm_Client.py脚本调用WebService上传告警信息   
    Send_Alarm_Client.py  ----  调用WebService上传告警信息 

###二、基站WebService构建--PHPService目录
####1、services目录下文件说明

	FSUINFO.db --- FSU信息SQlite数据库      
	history.db --- 基站传感器实时信息和历史信息数据库           
	changeip.sh  --- 动态配置wsdl的IP地址的脚本                       
	FSUService.php   --- 基站WebService的PHP实现文件
	FSUService.wsdl  --- 基站WebService的WSDL配置文件 

###三、基站VPN构建--VPNConfig目录
####1、文件的简要说明
	python文件 -------  连接VPN和保证VPN重连的python脚本，vpnstart.py是主要文件，阅读可理解所有文件作用
	sh文件 ----- 连接VPN和保证VPN重连的shell脚本，vpnstart.sh用来连接vpn

    
     
     
     
     