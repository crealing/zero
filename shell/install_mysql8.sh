#!/bin/bash
#

# 二进制安装mysql8.0




function install_mysql8(){
	
	INSTALL_DIR=/usr/local
	S_NAME=mysql
	SOURCE_DIR=/usr/local/src
	#REMOTE_URL=https://downloads.mysql.com/archives/get/file
	REMOTE_URL=http://192.168.0.150/zip
	FILE_NAME=mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz
	
	DATA_DIR=/data/mysql
	GROUP=mysql
	USER=mysql

	CONF_FILE=/etc/my.cnf

	#检测是否安装mysql
	if [ -d ${INSTALL_DIR}/${S_NAME} ]; then
		fail "Install Dir[${INSTALL_DIR}/${S_NAME} ] Exsist, Please Check It"
		exit 9
	fi

	if [ ! -f  "${SOURCE_DIR}/${FILE_NAME}" ]; then
		wget -P  ${SOURCE_DIR} ${REMOTE_URL}/${FILE_NAME}
	fi
	
	tar xvf ${SOURCE_DIR}/${FILE_NAME} -C  ${INSTALL_DIR} && ln -s ${INSTALL_DIR}/${FILE_NAME%.tar*} ${INSTALL_DIR}/${S_NAME} && cd ${INSTALL_DIR}/${S_NAME}
	#echo "tar xvf ${SOURCE_DIR}/${FILE_NAME} -C  ${INSTALL_DIR}/${S_NAME}"
	#exit 3
	cd ${INSTALL_DIR}/${S_NAME}
	if [ $? -eq 0 ]; then
		#创建数据文件夹
		if [ ! -d "$DATA_DIR" ]; then
			mkdir -p "$DATA_DIR"
		fi
		
		#创建mysql用户
		if ! id -u ${USER} &>/dev/null; then
			groupadd ${GROUP}
			useradd -r -s /sbin/nologin -g ${GROUP} -M  ${USER}
		fi

		chown -R mysql.mysql ${INSTALL_DIR}/${S_NAME}
		chown -R mysql.mysql $DATA_DIR
		
		#创建配置文件
		if [ -f ${CONF_FILE} ]; then
			cp ${CONF_FILE} ${CONF_FILE}.bak
		fi
		cat << EOF > ${CONF_FILE}
[mysqld]
port=3306
socket=/tmp/mysql.sock
basedir=${INSTALL_DIR}/${S_NAME}
datadir=$DATA_DIR
log-error=mysql_err.log
server-id=330601
EOF

		#初始化数据库
		#有密码
		#${INSTALL_DIR}/${S_NAME}/bin/mysqld --defaults-file=${CONF_FILE} --user=${USER} --initialize
		#无密码
		${INSTALL_DIR}/${S_NAME}/bin/mysqld --defaults-file=${CONF_FILE} --user=${USER} --initialize-insecure
		if [ $? -eq 0 ]; then
			success "Mysql Initailize Successfully!"
		else
			fail "Mysql Initailize Failed!"
			exit 2
		fi

		#启动数据库
		${INSTALL_DIR}/${S_NAME}/bin/mysqld_safe --defaults-file=${CONF_FILE} --user=${USER} &
		if ps aux | grep mysql &> /dev/null; then
			success "Mysql Start Successfully!"
		else
			fail "Mysql Start Failed!"
			exit 3
		fi

		
		#配置环境变量
		echo 'PATH='${INSTALL_DIR}/${S_NAME}/bin/':$PATH' > /etc/profile.d/mysql.sh && ./etc/profile.d/mysql.sh
		if [ $? -eq 0 ]; then
			success "Env Set Successfully!"
		else
			fail "Env Set Failed!"
			exit 4
		fi
		

		#登录数据库设置密码
		${INSTALL_DIR}/${S_NAME}/bin/mysql << EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Xwb@2019';
\q;
EOF
		success "Mysql Password Set Successfully!"
		
		#将mysql服务加到系统服务中
		cp -a ${INSTALL_DIR}/${S_NAME}/support-files/mysql.server /etc/init.d/mysql.server
		chmod +x /etc/init.d/mysql.server
		chkconfig --add mysql.server
		success "Mysql Server Add Successfully!"
	else
		fail "Unzip Failed!"
		exit 1
	fi

}

function  success(){
	echo -e "\033[32m $1 \033[0m"
	return 0
}

function fail(){
	echo -e "\033[31m $1 \033[0m"
	return 0
}

install_mysql8