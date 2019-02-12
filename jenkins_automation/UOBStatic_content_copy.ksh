#!/usr/bin/ksh

if [ $# -ne 2 ]
then
        # if  FIID and Static JAR are not passed, send error and exit
        echo " Usage: $0 <FIID> <Static JAR>"
	echo " Example: $0 fisq1 Static_UBxxx.jar"
        exit 1
fi

cwd="/packages/automation"
fiid=$1
uob_stat=$2

usrid=root
idfi=`echo ${fiid#??}`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`
blop=192.168.192.78

srvr_nm=`ssh ${usrid}@${blop} "hostname"`
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_static_${srvr_nm}.log"

echo "------------------------------------------------------"

if [ -f ${logfile} ]
then
  mv ${logfile} ${logfile}_$((1 + `ls -d ${logfile}* | wc -l`))
fi

## This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/dtout >&3 &
pid_out=$!
exec  1>${logpath}/dtout
exec  2>${logpath}/dtout
date

#### Identifying which packages to push
pkg_ver=`echo ${uob_stat} | awk 'BEGIN { FS="_" }{ print $2 }' |awk -F"UB" '{print $2}'`

#### Copying static content packages to bloprpt1
arr[0]=/platform/${fiid}/EP/build/${uob_stat}
file2scp=`echo ${arr[*]}`

echo " COPYING STATIC CONTENT JAR ${file2scp} to bloprpt1 \n"
scp ${file2scp} ${usrid}@${blop}:/tmp/

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/dtout

echo "${dt},${pkg_ver},${srvr_nm},${webs}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl

exit 0
