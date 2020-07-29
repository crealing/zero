#!/bin/bash
#Author: xiaowen
#Time:2020-07-29 09:58:27

#定义相关参数
PORT=80
VIP=172.16.10.150
RIP=(192.168.0.130 192.168.0.131)

#启动
start(){
	#echo 1 > /proc/sys/net/ipv4/ip_forward
	ifconfig ens33:0 $VIP netmask 255.255.255.0 up
	route add -host $VIP dev ens33
	
	#清空LVS规则
	ipvsadm -C

	ipvsadm -A -t $VIP:$PORT -s wrr
	for(( i=0; i<${#RIP[*]}; i++)) do
		ipvsadm -a -t $VIP:$PORT -r ${RIP[$i]}:$PORT -g -w 1
	done
}

stop(){
	ipvsadm -C
	ifconfig ens33:0 down
	route del -host $VIP dev ens33
}

case "$1" in
	start)
		start
		echo 'ipvs start'
	 ;;
	 stop)
		stop
		echo 'ipvs stop'
		;;
	 restart)
		stop
		echo 'ipvs is stop'
		start
		echo 'ipvs is start'
	 ;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
	 ;;
esac

