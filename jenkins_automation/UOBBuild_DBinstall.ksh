#!/usr/bin/ksh

if [ $# -ne 5 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID> <DB instance> <DBServer EXT IP> <DB Target> <DB instance passwd>"
	echo " Example: $0 fiewbk diewbk 172.30.4.X custom-database-deploy diewbk"
        exit 1
fi

#cwd=`pwd`
cwd="/packages/automation"
fiid=$1
dbid=$2
dbpass=$3
dbtarget=$4
dbserver=$5
idfi=`echo ${fiid#??}`
#dt=`date +"%d%b%Y%H%M%S"`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`

srvr_nm=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${dbid}@${dbserver} "hostname"`
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/DBinstall_${srvr_nm}.log"

#### Checking if script is run by mistake
if [ ! -f ${pkgpath}/blddtl ] || [ ! -f ${logpath}/build_pass2.log ] || [ ! -f ${logpath}/pkg_info ]
then
        echo
	echo "-------------------------------------------------------------------"
	echo "ERROR: There are no build details available for now ...."
        echo "You seem to have run this job by mistake .... "
        echo "Execute Pass1 & Pass2 jobs before running DB install job ...."
        echo "Exiting ..................................................."
	echo "-------------------------------------------------------------------"
	echo
        exit 1
fi

if [ -f ${logfile} ]
then
        mv ${logfile} ${logfile}_$((1 + `ls -d ${logfile}* | wc -l`))
fi

##### This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/$dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/$dtout >&3 &
pid_out=$!
exec  1>${logpath}/$dtout
exec  2>${logpath}/$dtout
echo "------------------------------------------------------"
date;echo

#### Identifying which DB JAR to push
pkg_ver=`awk -F"UB|EB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`

#### Copying DB JAR to dbserver
file2scp=`grep DB ${logpath}/pkg_info`
dbjar=`grep DB ${logpath}/pkg_info|awk -F'build/' '{print $2}'`

stage=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${dbid}@${dbserver} "echo '. \\${HOME}/.profile >/dev/null 2>&1 \n cd /platform/${fiid}/EP \n pwd ' > /tmp/drst.sh ; /usr/bin/ksh /tmp/drst.sh ; rm /tmp/drst.sh"`
echo "STAGING PATH = ${stage} \n" 2>&1
echo "COPYING FILES ${file2scp}  to ${stage} \n" 2>&1
scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/UOBsubprgm_DBinstall.ksh ${dbid}@${dbserver}:${stage}/ 2>&1

echo "###########################################################"
echo "# Starting DBinstall of DB JAR on dbserver ${srvr_nm}     #"
echo "###########################################################"

ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${dbid}@${dbserver} "chmod 755 ${stage}/UOBsubprgm_DBinstall.ksh ; ${stage}/UOBsubprgm_DBinstall.ksh $dbjar $fiid $dbid $dbpass $dbtarget" 2>&1
success_code=$?
case $success_code in
        0) echo " " ;;
        1) echo " " ;;
        2) echo "\nBuild Deployment Failed at Link Creation" ;;
        3) echo "\nBuild Deployment Failed at Deploy Step " ;;
        4) echo "\nBuild Deployment Failed at Install Step " ;;
        5) echo "\nBuild Deployment Failed at Stopping Application " ;;
        6) echo "\nBuild Deployment Failed at Starting Application " ;;
        *) echo "\nBuild Deployment Failed with unknown reasons " ;;
esac

echo "------------------------------------------------------"

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/$dtout
echo "${dt},${pkg_ver},${srvr_nm},${dbserver}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl

if [ ${success_code} -eq 0 ]
then
        echo "DBinstall completed successfully for ${fiid} on ${srvr_nm}"
        echo "Check email for details";
        echo "------------------------------------------------------"
        date
        echo "------------------------------------------------------"
        ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${dbid}@${dbserver} "rm ${stage}/UOBsubprgm_DBinstall.ksh"

	mail -r "dmsbuild@bankonline.com"  -s "DBinstall completed for ${fiid} on app server ${srvr}" amit.tarwade@aciworldwide.com < ${logpath}/rndnum

else
        echo "DBinstall Failed for ${fiid}, check logs on DB server ${srvr_nm}"
        echo "------------------------------------------------------"
        date
        echo "-----------------------------------------------------"
        ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${dbid}@${dbserver} "rm ${stage}/UOBsubprgm_DBinstall.ksh"
        exit 1
fi
