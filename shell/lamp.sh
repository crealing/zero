#!/bin/bash

#auto make install LAMP
#author: xiaowen

#arp和apr-util依赖
APR_FILES=apr-1.6.2.tar.gz
APR_FILES_DIR=/usr/local/src/apr-1.6.2
APR_URL=http://archive.apache.org/dist/apr
APR_PREFIX=/usr/local/apr

APR_UTIL_FILES=apr-util-1.6.0.tar.gz
APR_UTIL_FILES_DIR=/usr/local/src/apr-util-1.6.0
APR_UTIL_URL=http://archive.apache.org/dist/apr
APR_UTIL_PREFIX=/usr/local/apr-util

#pcre
PCRE_FILES=pcre-8.37.tar.gz
PCRE_FILES_DIR=/usr/local/src/pcre-8.37
PCRE_URL=https://nchc.dl.sourceforge.net/project/pcre/pcre/8.37
PCRE_PREFIX=/usr/local/pcre

#Http define path variable
H_FILES=httpd-2.4.27.tar.gz
H_FILES_DIR=/usr/local/src/httpd-2.4.27
H_URL=http://archive.apache.org/dist/httpd
H_PREFIX=/usr/local/apache

#MySQL define path variable
M_FILES=mysql-5.6.39.tar.gz
M_FILES_DIR=/usr/local/src/mysql-5.6.39
M_URL=http://mirrors.sohu.com/mysql/MySQL-5.6
M_PREFIX=/usr/local/mysql/

#PHP define path variable
P_FILES=php-5.6.13.tar.gz
P_FILES_DIR=/usr/local/src/php-5.6.13
P_URL=http://mirrors.sohu.com/php/
P_PREFIX=/usr/local/php


if [ -z "$1" ];then
	echo -e "\033[32m Please Select Install Menu follow: \033[1m"
	echo -e "1)编译安装Apache服务器"
	echo -e "2)编译安装MySQL服务器"
	echo -e "3)编译安装PHP服务器"
	echo -e "4)配置index.php并启动LAMP服务"
	echo -e "\033[31m Usage:{ /bin/sh $0 1|2|3|4|help} \033[0m"
fi

if [[ "$1" -eq "1" ]];then
	
	#检测是否安装httpd
	if `service httpd restart &> /dev/null`; then
		echo -e "\033[31m Httpd server 已安装，请勿重复安装！ \033[0m"
		exit 1
	fi
		
	echo -e "\033[32m 准备安装Apache依赖... \033[0m"
	yum groupinstall "Development Tools" "Development Libraries" -y
	yum install gcc gcc-c++ openssl-devel expat-devel -y

	#Install apr
	echo -e "\033[32m 准备安装apr... \033[0m"
	wget -c $APR_URL/$APR_FILES && tar -zxvf $APR_FILES -C /usr/local/src && cd $APR_FILES_DIR; ./configure --prefix=$APR_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		echo -e "\033[32m The Apr Install Successfully! \033[0m"
	else
		echo -e "\033[32m The Apr Install Failed,Please check! \033[0m"
		exit
	fi

	#Install apr-util
	echo -e "\033[32m 准备安装apr-util... \033[0m"
	wget -c $APR_UTIL_URL/$APR_UTIL_FILES && tar -zxvf $APR_UTIL_FILES -C /usr/local/src && cd $APR_UTIL_FILES_DIR; ./configure --prefix=$APR_UTIL_PREFIX --with-apr=$APR_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		echo -e "\033[32m The Apr-util Install Successfully! \033[0m"
	else
		echo -e "\033[32m The Apr-util Install Failed,Please check! \033[0m"
		exit
	fi

	#Install pcre
	echo -e "\033[32m 准备安装pcre... \033[0m"
	wget -c $PCRE_URL/$PCRE_FILES && tar -zxvf $PCRE_FILES -C /usr/local/src && cd $PCRE_FILES_DIR; ./configure --prefix=$PCRE_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		echo -e "\033[32m The Pcre Install Successfully! \033[0m"
		echo -e "\033[32m All Dependency Packages Are Installed Successfully! \033[0m"
	else
		echo -e "\033[32m The Pcre Install Failed,Please check! \033[0m"
		exit
	fi
	
	#Install Httpd Server
	echo -e "\033[32m 准备安装Httpd Server... \033[0m"
	wget -c $H_URL/$H_FILES && tar -zxvf $H_FILES -C /usr/local/src && cd $H_FILES_DIR ; ./configure --prefix=$H_PREFIX --enable-so --enable-rewrite --enable-ssl --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=event
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		echo -e "\033[32m The Httpd Server Install Successfully! \033[0m"
		useradd -M -s /sbin/nologin apache
		chown -R apache:apache /usr/local/apache/
		cp /usr/local/apache/bin/apachectl /etc/init.d/httpd
		sed -i "9a # chkconfig:2345 64 36" /etc/init.d/httpd
		sed -i "197a ServerName localhost:80" /usr/local/apache/conf/httpd.conf
		sed -i "s/^User/User apache/g" /usr/local/apache/conf/httpd.conf
		sed -i "s/^Group/Group apache/g" /usr/local/apache/conf/httpd.conf
		#chkconfig --add httpd
		#service httpd start
	#	cat << EOF >> /lib/systemd/system/httpd.service
	#	[Unit]
	#	Description=The Apache HTTP Server
	#	After=network.target

	#	[Service]
	#	Type=forking
	#	PIDFile=/usr/local/httpd/logs/httpd.pid
	#	ExecStart=/usr/local/bin/apachectl $OPTIONS
	#	ExecReload=/bin/kill -HUP $MAINPID
	#	KillMode=process
	#	Restart=on-failure
	#	RestartSec=42s

	#	[Install]
	#	WantedBy=multi-user.target
	#	EOF
		chkconfig --add httpd
		service httpd start
		netstat -tlunp | grep 80 &> /dev/null
		if [ $? -eq 0 ];then 
			echo -e "\033[32m *httpd服务已启动！\033[0m"
		else
			echo -e "\033[31m Error:httpd服务启动失败！ \033[0m"
		fi
	else
		echo -e "\033[32m The Httpd Server Install Failed,Please check! \033[0m"
		exit
	fi
fi


#Install MySQL
if [[ "$1" -eq "2" ]];then
	if `service mysqld start &> /dev/null`; then
		echo -e "\033[31m mysqld 已安装，请勿重复安装！ \033[0m"
		exit 1	
	fi
	yum remove -y mysql mysql-server
	rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64
	yum install -y cmake ncurses-devel;
	useradd -M -s /sbin/nologin mysql
	wget -c $M_URL/$M_FILES && tar -zxvf $M_FILES -C /usr/local/src && cd $M_FILES_DIR
	cmake \
	-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
	-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_EXTRA_CHARSETS=all \
	-DWITH_MYISAM_STORAGE_ENGINE=1 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_MEMORY_STORAGE_ENGINE=1 \
	-DWITH_READLINE=1 \
	-DENABLED_LOCAL_INFILE=1 \
	-DMYSQL_DATADIR=/usr/local/mysql/data \
	-DMYSQL-USER=mysql
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
	else
		echo -e "\033[31m The MySQL Server Install Failed,Please check! \033[0m"
		exit
	fi
	chown -R mysql:mysql /usr/local/mysql/
	/bin/cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
	/bin/cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	sed -i 's%^basedir=%basedir=/usr/local/mysql%' /etc/init.d/mysqld
	sed -i 's%^datadir=%datadir=/usr/local/mysql/data%' /etc/init.d/mysqld
	chkconfig --add mysqld
	chkconfig mysqld on
	/usr/local/mysql/scripts/mysql_install_db \
	--defaults-file=/etc/my.cnf \
	--basedir=/usr/local/mysql/ \
	--datadir=/usr/local/mysql/data/ \
	--user=mysql
	if [ $? -eq 0 ];then
		echo -e "033[32m The MySQL Server Install Successfully! \033[0m"
		ln -s /usr/local/mysql/bin/* /bin/
		if `service mysqld start &> /dev/null`; then 
			echo -e "033[32m The MySQL Server start Successfully! \033[0m"
		else
			echo -e "033[31m The MySQL Server start Failed! \033[0m"
		fi
	else
		echo -e "033[31mThe MySQL Server Install Failed,Please check!\033[0m"
	exit
	fi
fi
