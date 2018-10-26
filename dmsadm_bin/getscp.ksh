#!/bin/ksh

host=`hostname`
tty|cut -f3,4 -d"/"|read Tty;who|grep $Tty|awk '{print $1}'|read MYLOGIN
ip=$(grep " $host" /etc/hosts | cut -d' ' -f1)
dir=$PWD
file=$(ls -tr DB*.jar | tail -1)
echo "scp $MYLOGIN@${ip}:${dir}/${file} ."

