# -*- coding: utf-8 -*-
"""
Created on Sat May 30 00:17:06 2015

@author: Stroot
"""

import os
import requests
from requests.auth import HTTPDigestAuth
import time
from xml.dom import minidom

# 基本配置信息
IP = '192.168.1.64'
username = 'admin'
password = 'admin1234'

BASE_URL = 'http://%s' % IP
auth_instance = HTTPDigestAuth(username, password)

###################################################
#登录
EXT_URL = '/ISAPI/Security/userCheck?timeStamp=%d' % time.time()
URL = '%s%s' % (BASE_URL, EXT_URL)
response = requests.get(URL, auth=auth_instance)
#简单异常处理。
if response.status_code != requests.codes.ok:
    print 'Error in request: %s' % URL
    os.exit()
#print response.content

###################################################
#获取通道ID。
EXT_URL = '/Streaming/channels'
URL = '%s%s' % (BASE_URL, EXT_URL)
response = requests.get(URL, auth=auth_instance)
#简单异常处理。
if response.status_code != requests.codes.ok:
    print 'Error in request: %s' % URL
    os.exit()
#print response.content

#
xmldoc = minidom.parseString(response.content)
channelListRoot = xmldoc.getElementsByTagName('StreamingChannelList')
#如果没有channelList，直接退出。
if len(channelListRoot) == 0:
    os.exit()

channelList = channelListRoot[0].getElementsByTagName('StreamingChannel')
#如果没有channel，直接退出。
if len(channelList) == 0:
    os.exit()

channelIDList = []
for channel in channelList:
    channelIDList.append(channel.getElementsByTagName('id')[0].firstChild.data)
#print channelIDList    
    
###################################################
#获取第一个通道图像并保存。
channelID = int(channelIDList[0])
EXT_URL = '/Streaming/channels/%d/picture?snapShotImageType=JPEG' % channelID
URL = '%s%s' % (BASE_URL, EXT_URL)
response = requests.get(URL, auth=auth_instance)
#简单异常处理。
if response.status_code != requests.codes.ok:
    print 'Error in request: %s' % URL
    os.exit()

#保存文件。
try:
    fileHandle = open ('/home/pi/PIC/%s.jpg' % time.strftime('%Y-%m-%d-%H-%M-%S'), 'wb' )
    fileHandle.write (response.content)
    fileHandle.close()
except Exception, e:
    print e
