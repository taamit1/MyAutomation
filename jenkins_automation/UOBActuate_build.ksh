#!/usr/bin/ksh

if [ $# -ne 1 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID> "
	echo " Example: $0 fisq1 "
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
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_actuate_${srvr_nm}.log"

#### Checking if script is run by mistake
if [ ! -f ${pkgpath}/blddtl ] || [ ! -f ${logpath}/pkg_info ]
then
	echo "There is no build detail available for now ....\n"
	echo "You seem to have run the script by mistake .... \n"
	echo "Execute Pass1 & 2  before running Pass3 .... \n"
	echo "Exiting ..................................................."
	exit 1
fi

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
pkg_ver=`awk -F"UB|EB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`

#### Copying Actuate JAR to bloprpt1
file2scp=`grep -E "Actuate" ${logpath}/pkg_info | tr "\n" " "`
echo " COPYING ACTUATE JAR ${file2scp} to bloprpt1 \n"
scp ${logpath}/pkg_info ${file2scp} ${usrid}@${blop}:/tmp/

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/dtout

echo "${dt},${pkg_ver},${srvr_nm},${webs}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl

exit 0
