#!/usr/bin/ksh

if [ $# -ne 1 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID>"
	echo " Example: $0 fisq1"
        exit 1
fi

cwd="/packages/automation"
fiid=$1
usrid=root
idfi=`echo ${fiid#??}`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`
blop=192.168.192.78

srvr_nm=`ssh ${usrid}@${blop} "hostname"`
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/istblddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_actuate_${srvr_nm}.log"

#### Checking if script is run by mistake
if [ ! -f ${pkgpath}/istblddtl ] || [ ! -f ${logpath}/ist_build_pass1.log ]
then
	echo "There is no build detail available for now ...."
	echo "You seem to have run the script by mistake ...."
	echo "Execute Pass1 before running actuate copy job ...."
	echo "Exiting .........................................."
	exit 1
fi

if [ -f ${logfile} ]
then
        mv ${logfile} ${logfile}_$((1 + `ls -d ${logfile}* | wc -l`))
fi

##### This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/dtout >&3 &
pid_out=$!
exec  1>${logpath}/dtout
exec  2>${logpath}/dtout
date

#### Identifying which packages to push
buildApp_log=`grep "Recording" ${logpath}/ist_build_pass1.log |grep buildApp|uniq|awk -F"at" '{print $2}'|awk -F" " '{print $1}'`
pkg_ver=`awk -F"UB|EB" '/FI_BLD_VER/ {print $2}' $buildApp_log|awk -F"\'" '{print $1}'`
grep $pkg_ver $buildApp_log|egrep '.jar|.ear'|awk -F":" '{print $2}' | sort | uniq > ${logpath}/pkg_info

#### Copying Actuate JAR to bloprpt1
file2scp=`grep -E "Actuate" ${logpath}/pkg_info | tr "\n" " "`
echo " COPYING IST ACTUATE JAR ${file2scp} to bloprpt1 \n"
scp ${logpath}/pkg_info ${file2scp} ${usrid}@${blop}:/tmp/

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/dtout

echo "${dt},${pkg_ver},${srvr_nm},${webs}" >> ${pkgpath}/audit_istblddtl
echo "${dt}" >> ${pkgpath}/old_istblddtl

exit 0
