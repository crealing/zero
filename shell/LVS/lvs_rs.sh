#!/bin/bash
#Author: xiaowen
#Time:2020-07-29 10:15:22

VIP=192.168.0.180
PORT=80

case "$1" in
	start)
		ifconfig lo:0 $VIP netmask 255.255.255.255 up
		route add -host $VIP dev lo
		echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
		echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce
		echo "start LVS of RealServer"
	 ;;
	stop)
		ifconfig lo:0 $VIP/32 down
		route del -host $VIP dev lo
		echo "0" > /proc/sys/net/ipv4/conf/lo/arp_ignore
		echo "0" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_announce
		echo "stop LVS of RealServer"
	 ;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
	 ;;
esac
