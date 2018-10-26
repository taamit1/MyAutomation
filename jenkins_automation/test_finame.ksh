usrid=$1

grep "usr" ${usrid} >>/dev/null 2>&1
if test $? -eq 0
then
   echo ${usrid}
   finame=`echo ${usrid}|sed s/usr/fi/`
   echo $finame
else
   finame=`echo ${usrid}|sed s/us/fi/`
   echo $finame
fi
