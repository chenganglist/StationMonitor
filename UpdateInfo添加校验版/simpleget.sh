#!/bin/bash
cd /home/pi/UpdateInfo
echo  "温度一号：""$(cat decimal_temperature1)"
echo  "温度二号：""$(cat decimal_temperature2)"
echo  "湿度一号："$(cat decimal_humidity1)
echo "湿度二号："$(cat decimal_humidity2)
echo "第一组蓄电池组前半组电压："$(cat forward_half_battery_voltage1)
echo "第一组蓄电池组后半组电压："$(cat backward_half_battery_voltage1)
echo "第一组蓄电池组总电压："$(cat total_battery_group_voltage)
echo "第二组蓄电池组前半组电压："$(cat forward_half_battery_voltage2)
echo "第二组蓄电池组后半组电压："$(cat backward_half_battery_voltage2)
echo "第二组蓄电池组总电压："$(cat total_battery_group_voltage2)
echo "烟感""$(cat io_smoke1)""$(cat io_smoke2)""$(cat io_smoke3)""$(cat io_smoke4)"
###################门磁#############################
echo "门磁""$(cat door_magnetic1)""$(cat door_magnetic2)""$(cat door_magnetic3)""$(cat door_magnetic4)"
echo "水浸""$(cat soak_resist1)""$(cat soak_resist2)""$(cat soak_resist3)""$(cat soak_resist4)"
echo "外机防盗""$(cat burglar_resist1)""$(cat burglar_resist2)"
#########################红外######################
echo "红外""$(cat infared1)""$(cat infared2)"
