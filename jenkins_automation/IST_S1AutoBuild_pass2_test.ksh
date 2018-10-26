#!/usr/bin/ksh
if [ "x$1" == "x" ] || [ "x$2" == "x" ] || [ "x$3" == "x" ]
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

#stage="/platform/${fiid}/WebSphere/DeploymentManager/Stage"
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_pass3_${dmgr}.log"

#### Checking if script is run by mistake ---- once again boaring stuff to code  ????%$ NOT AGAIN
if [ ! -f ${pkgpath}/blddtl ]
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

##### This is for logging intelegance --- stopy copy paste man (to me)
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/$dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/$dtout >&3 &
pid_out=$!
exec  1>${logpath}/$dtout
exec  2>${logpath}/$dtout

date
#### Identifying which packages to push
pkg_ver=`awk -F"EP|CI|CB|TO|NA|UB|OB" '/Build/ {gsub(/\./,"");print $2}' ${logpath}/build_pass1.log| head -1| awk -F"for" '{print $1}'`
grep $pkg_ver ${logpath}/build_pass1.log|awk -F":" '{print $2}' | sort | uniq > ${logpath}/pkg_info

#### Copying packages to DMGR
file2scp=`grep -E "Config|build/EP" ${logpath}/pkg_info | tr "\n" " "`

stage=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "echo '. \\${HOME}/.profile \n tostage \n pwd ' > /tmp/drst.sh ; /usr/bin/ksh /tmp/drst.sh ; rm /tmp/drst.sh"`
echo " STAGING PATH = ${stage} \n"
echo " COPYING FILES ${file2scp}  to ${stage} \n"
echo "scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/IST_subprgm_pass2.ksh ${usrid}@${dmgr}:${stage}/"
scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/IST_subprgm_pass2.ksh ${usrid}@${dmgr}:${stage}/
#scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${cwd}/IST_subprgm_pass2.ksh ${usrid}@${dmgr}:${stage}/

###### Execute build on DMGR
echo "+++++++++++++++++++++++++++++++++++"
echo "+ Executing Build on DMGR ${dmgr} +"
echo "+++++++++++++++++++++++++++++++++++"

echo "ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} \"chmod 755 ${stage}/IST_subprgm_pass2.ksh ; ${stage}/IST_subprgm_pass2.ksh ${pkg_ver} ${fiid}\""
#ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "chmod 755 ${stage}/IST_subprgm_pass2.ksh ; ${stage}/IST_subprgm_pass2.ksh ${pkg_ver} ${fiid}"
success_code=$?

case $success_code in
	0) echo "\nBuild Deployment is Success" ;;
	1) echo "\nBuild Deployment Failed at Link Creation" ;;
	2) echo "\nBuild Deployment Failed at Deploy Step " ;;
	3) echo "\nBuild Deployment Failed at Install Step " ;;
	4) echo "\nBuild Deployment Failed at Stopping Application " ;;
	5) echo "\nBuild Deployment Failed at Starting Application " ;;
	*)  echo "\nBuild Deployment Failed for Unknown Reasons" ;;
esac

if [ ${success_code} -eq 0 ]
then
	echo "\nBuild deployed Successfully for ${fiid}"
	ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/IST_subprgm_pass2.ksh"
	echo "Check email for details"
else
	echo "Build deployed failed for ${fiid}"
	ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/IST_subprgm_pass2.ksh"
	exit 1
fi

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/$dtout

##### Composing build email
srvr=`awk -F":" '/Server Name/ {print $2}' ${logfile}`
echo "All,\nThe deployment of the following new EAR/JAR has been completed on (SPECIFY BANK/ENV HERE)(${srvr}). Server is up and available for testing." > ${logpath}/rndnum
echo "Please respond within 24 hours that you have reviewed the environment and fixes. Provide any issues encountered during testing.\n" >> ${logpath}/rndnum

#echo "New EAR/JAR Details:" >> ${logpath}/rndnum
#echo "--------------------" >> ${logpath}/rndnum
echo "       " `awk -F":" '/New_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "       " `awk -F":" '/New_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "\n"  >> ${logpath}/rndnum

echo "The following EAR/JAR is available for back out purpose located at Stage: \n" >> ${logpath}/rndnum
echo "       " `awk -F":" '/Old_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "       " `awk -F":" '/Old_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum

#mail -r "dmsbuild@bankonline.com"  -s "Build Update for ${fiid}" "EPOperationsSystemEngandAdminTeam@aciworldwide.com,pune-hosting-app@aciworldwide.com" < ${logpath}/rndnum
exit 0
