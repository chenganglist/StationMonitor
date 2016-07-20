#!/bin/bash
wvdial &
sleep 10
service xl2tpd restart
sleep 10
echo "c Wan" > /run/xl2tpd/l2tp-control

