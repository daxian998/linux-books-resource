#!/bin/bash
##根据进程名“杀死”指定进程
##__author__ is humingzhe
##email admin@humingzhe.com
#从终端接收第一个参数，系统本身默认当前 shell 为第 0 个参数$0

param=$1

#启动进程函数
start()
{
	fpms=`ps aux | grep -i "mysqld" | grep -v grep | awk '{print $2}'`
	#当前进程不为空，-n 用于判断变量的值是否为空
	if [ ! -n "$fpms" ]; then
	#启动进程
		/usr/local/mysql/bin/mysqld&
		echo "mysqld Start"
	else
		echo "mysqld Already Start"
	fi
}

#停止进程
stop()
{
	fpms=`ps aux | grep -i "mysqld" | grep -v grep | awk '{print $2}'`
	echo $fpms | xargs kill -9
	
	for pid in $fpms; do
		if	echo $pid | egrep -q '^[0-9]+$'; then
			echo "MySQLD Pid $pid Kill"
		else
			echo "$pid IS Not A MySQLD Pid"
		fi
	done
}

#switch 调用

case $param in
	'start')
		start;;
	'stop')
		stop;;
	'restart')
		stop
		start;;
	*)
		echo "Usage: sh kill.sh start|stop|restart";;
esac
