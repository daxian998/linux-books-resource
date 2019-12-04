#!/bin/bash
# written by HuMingZhe
# Email：admin@humingzhe.com
# QQ：512289389
# 网址：https://humingzhe.com
fwm=6
sorry_server=127.0.0.1
rs=('192.168.18.7' '192.168.18.8')
rw=('1' '2')
type='-g'
chkloop=3
rsstatus=(0 0)
logfile=/var/log/ipvs_health_check.log

addrs() {
    ipvsadm -a -f $fwm -r $1 $type -w $2
    [ $? -eq 0 ] && return 0 || return 1
}

delrs() {
    ipvsadm -d -f $fwm -r $1
    [ $? -eq 0 ] && return 0 || return 1
}

chkrs() { 
    local i=1
    while [ $i -le $chkloop ]; do
        if curl --connect-timeout 1 -s http://$1/.health.html | grep "OK" &> /dev/null; then
            return 0
        fi
        let i++
        sleep 1
    done
    return 1
}

initstatus() {
    for host in `seq 0 $[${#rs[@]}-1]`; do 
        if chkrs ${rs[$host]}; then
            if [ ${rsstatus[$host]} -eq 0 ]; then
                rsstatus[$host]=1
            fi
        else
            if [ ${rsstatus[$host]} -eq 1 ]; then
                rsstatus[$host]=0
            fi
        fi
    done
}

initstatus
while :; do
    for host in `seq 0 $[${#rs[@]}-1]`; do 
        if chkrs ${rs[$host]}; then
            if [ ${rsstatus[$host]} -eq 0 ]; then
                addrs ${rs[$host]} ${rw[$host]}
                [ $? -eq 0 ] && rsstatus[$host]=1
            fi
        else
            if [ ${rsstatus[$host]} -eq 1 ]; then
                delrs ${rs[$host]} ${rw[$host]}
                [ $? -eq 0 ] && rsstatus[$host]=0
            fi
        fi
    done
    sleep 5
done