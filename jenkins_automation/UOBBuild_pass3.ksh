#!/usr/bin/ksh

if [ $# -ne 3 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID> <App. USER ID> <DMGRi EXT IP>"
	echo " Example: $0 fi9999 usrXXXX 172.30.4.X"
        exit 1
fi

#cwd=`pwd`
cwd="/packages/automation"
fiid=$1
usrid=$2
dmgr=$3
idfi=`echo ${fiid#??}`
#dt=`date +"%d%b%Y%H%M%S"`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`

srvr_nm=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "hostname"`
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/deploy_pass3_${srvr_nm}.log"

#### Checking if script is run by mistake
if [ ! -f ${pkgpath}/blddtl ] || [ ! -f ${logpath}/build_pass2.log ] || [ ! -f ${logpath}/pkg_info ]
then
        echo
	echo "-------------------------------------------------------------------"
	echo "ERROR: There are no build details available for now ...."
        echo "You seem to have run this job by mistake .... "
        echo "Execute Pass1 & Pass2 jobs before running Pass3 (Deploy) job ...."
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

#### Identifying which packages to push
pkg_ver=`awk -F"UB|EB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`

#### Copying packages to DMGR
file2scp=`grep -E "Config|build/EP" ${logpath}/pkg_info | tr "\n" " "`

stage=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "echo '. \\${HOME}/.profile >/dev/null 2>&1 \n tostage \n pwd ' > /tmp/drst.sh ; /usr/bin/ksh /tmp/drst.sh ; rm /tmp/drst.sh"`
echo "STAGING PATH = ${stage} \n" 2>&1
echo "COPYING FILES ${file2scp}  to ${stage} \n" 2>&1
scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/UOBsubprgm_pass3.ksh ${usrid}@${dmgr}:${stage}/ 2>&1

echo "###########################################################"
echo "# Starting the deployment of new build on DMGR ${srvr_nm} #"
echo "###########################################################"

ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "chmod 755 ${stage}/UOBsubprgm_pass3.ksh ; ${stage}/UOBsubprgm_pass3.ksh ${pkg_ver} ${fiid}" 2>&1
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
echo "${dt},${pkg_ver},${srvr_nm},${dmgr}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl

# Checking for scripting exceptions during deploy
#
grep "ScriptingException" ${logfile} >>/dev/null 2>&1
if test $? -eq 0
then
   echo "Deployment FAILED with Scripting Exception, check build/console logs"
   exit 2

elif [ ${success_code} -eq 0 ]
then
        echo "Build deployed successfully for ${fiid} on ${srvr_nm}"
        echo "Check email for details";
        echo "------------------------------------------------------"
        date
        echo "------------------------------------------------------"
        ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/UOBsubprgm_pass3.ksh"

        ## Composing build mail
	srvr=`awk -F":" '/Server Name/ {print $2}' ${logfile}`
	echo "All,\nThe deployment of the following new EAR/JAR has been completed on SPECIFY BANK/ENV HERE (${srvr}). Server is up and available for testing." > ${logpath}/rndnum
	echo "Please respond within 24 hours that you have reviewed the environment and fixes. Provide any issues encountered during testing.\n" >> ${logpath}/rndnum

	echo "       " `awk -F":" '/New_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
	echo "       " `awk -F":" '/New_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
	echo >> ${logpath}/rndnum

	echo "The following EAR/JAR is available for back out purpose located at Stage: \n" >> ${logpath}/rndnum

	echo "       " `awk -F":" '/Old_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
	echo "       " `awk -F":" '/Old_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum

	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" ramesh.bollempalli@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" bud.cook@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" Divya.Rajendran@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" ray.spiva@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" sharon.telljohn@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" joseph.thompson@aciworldwide.com < ${logpath}/rndnum

	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" Qamar.Khan@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" amit.tarwade@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" pallavi.kulkarni@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" sureshkumar.karajada@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" pankaj.zarekar@aciworldwide.com < ${logpath}/rndnum
	mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" narendra.edupuganti@aciworldwide.com < ${logpath}/rndnum

	#mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" EPOperationsSystemEngandAdminTeam@aciworldwide.com < ${logpath}/rndnum
else
        echo "Deployment Failed for ${fiid}, check logs on app server ${srvr_nm}"
        echo "------------------------------------------------------"
        date
        echo "-----------------------------------------------------"
        ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/UOBsubprgm_pass3.ksh"
        exit 1
fi
