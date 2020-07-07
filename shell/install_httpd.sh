#!/bin/bash

#编译安装httpd-2.4.27

source /shell/func.sh

function install_httpd(){
	#包含函数文件
	
	#success "ok"
	#exit

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



	#安装依赖
	yum groupinstall "Development Tools" "Development Libraries" -y
	yum install gcc gcc-c++ openssl-devel expat-devel -y

	#Install apr
	wget -c $APR_URL/$APR_FILES && tar -zxvf $APR_FILES -C /usr/local/src && cd $APR_FILES_DIR; ./configure --prefix=$APR_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		success "The Apr Install Successfully!"
	else
		fail "The Apr Install Failed,Please check!"
		exit 1
	fi

	#Install apr-util
	wget -c $APR_UTIL_URL/$APR_UTIL_FILES && tar -zxvf $APR_UTIL_FILES -C /usr/local/src && cd $APR_UTIL_FILES_DIR; ./configure --prefix=$APR_UTIL_PREFIX --with-apr=$APR_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		success "The Apr-util Install Successfully!"
	else
		fail "The Apr-util Install Failed,Please check!"
		exit 2
	fi

	#Install pcre
	wget -c $PCRE_URL/$PCRE_FILES && tar -zxvf $PCRE_FILES -C /usr/local/src && cd $PCRE_FILES_DIR; ./configure --prefix=$PCRE_PREFIX
	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		success "The Pcre Install Successfully!"	
	else
		echo -e "\033[32m The Pcre Install Failed,Please check! \033[0m"
		exit3
	fi

	#Install Httpd Server
	wget -c $H_URL/$H_FILES && tar -zxvf $H_FILES -C /usr/local/src && cd $H_FILES_DIR ; ./configure --prefix=$H_PREFIX --enable-so --enable-rewrite --enable-ssl --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=event

	if [ $? -eq 0 ];then
		make -j 4 && make install && cd
		success "The Httpd Server Install Successfully!"
		
		useradd -M -s /sbin/nologin apache

		chown -R apache:apache /usr/local/apache/
		cp /usr/local/apache/bin/apachectl /etc/init.d/httpd
		sed -i "9a # chkconfig:2345 64 36" /etc/init.d/httpd
		sed -i "197a ServerName localhost:80" /usr/local/apache/conf/httpd.conf

		sed -i "s/^User.*/User apache/g" /usr/local/apache/conf/httpd.conf
		sed -i "s/^Group.*/Group apache/g" /usr/local/apache/conf/httpd.conf
		chkconfig --add httpd
		service httpd start
	else
		fail "The Httpd Server Install Failed,Please check!"
		exit
	fi
}

install_httpd
