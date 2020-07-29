#!/bin/bash
#Author: xiaowen
#Time:2020-07-29 10:15:22

#vip��rip��ͬ����

VIP=172.16.10.150
ROUTE1=192.168.0.140
ROUTE2=172.16.10.100
PORT=80

case "$1" in
	start)
		#����arp����
		#echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
		#echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce
		#����VIP
		ifconfig lo:0 $VIP/32 up
		route add -host $VIP dev lo:0
		#�޸�RS���ݰ���������Ϊroute,�Ա�֤�ܺ����ͻ�ͨ��
		route del default
		route add default gw $ROUTE1
		echo "start LVS of RealServer"
	 ;;
	stop)
		#echo "0" > /proc/sys/net/ipv4/conf/lo/arp_ignore
		#echo "0" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_announce

		ifconfig lo:0 $VIP/32 down
		route del -host $VIP dev lo:0
		echo "stop LVS of RealServer"
	 ;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
	 ;;
esac
