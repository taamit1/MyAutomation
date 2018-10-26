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
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_static_${srvr_nm}.log"

#### Checking if script is run by mistake
echo "------------------------------------------------------"
if [ ! -f ${pkgpath}/blddtl ] || [ ! -f ${logpath}/pkg_info ] || [ ! -f ${logpath}/build_pass2.log ]
then
        echo "\nThere are no build details available for now ...."
        echo "You seem to have run this job by mistake .... "
        echo "Execute Pass1 & Pass2 jobs before running Static Deploy job .... "
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

#### Copying static content packages to bloprpt1
file2scp=`grep -E "Static" ${logpath}/pkg_info | tr "\n" " "`
echo " COPYING STATIC CONTENT JAR ${file2scp} to bloprpt1 \n"
scp ${logpath}/pkg_info ${usrid}@${blop}:/tmp/pkg_info_${fiid}
scp ${file2scp} ${usrid}@${blop}:/tmp/

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/dtout

echo "${dt},${pkg_ver},${srvr_nm},${webs}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl

exit 0
