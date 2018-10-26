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
pkg_ver=$4
idfi=`echo ${fiid#??}`
dt=`date +"%d%b%Y%H%M%S"`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`

srvr_nm=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "hostname"`
#stage="/platform/${fiid}/WebSphere/DeploymentManager/Stage"
crt_pkgpath="/platform/${fiid}/EP/build"
pkgpath="/packages/${fiid}"
#dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_custom_${srvr_nm}.log"

#### Checking if script is run by mistake ---- once again boaring stuff to code  ????%$ NOT AGAIN

if [ ! -d ${pkgpath}/${dt} ]
then
	mkdir ${pkgpath}/${dt}
fi


if [ -f ${logfile} ]
then
        mv ${logfile} ${logfile}_$((1 + `ls -d ${logfile}* | wc -l`))
fi




##### This is for logging intelegance --- stopy copy paste man (to me)

mkfifo ${logpath}/out.pipe
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/out.pipe >&3 &
pid_out=$!
exec  1>${logpath}/out.pipe
exec  2>${logpath}/out.pipe

date
#str="awk -F\":\" '/^d.{2}${idfi}/ {print \$1}' /etc/passwd"
#userid=`echo $str | ksh`
#sudo su - $userid -c " ${cwd}/UOBsubprgm_pass2.ksh ${fiid} ${dt}"



#### Identifying which packages to push

#pkg_ver=`awk -F"EP|CI|CB|TO|NA|UB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`

#### Copying packages to DMGR
#file2scp=`grep -E "Config|build/EP" ${logpath}/pkg_info | tr "\n" " "`
file2scp=`ls /platform/fi14673/EP/build/*3711H0V94*ar | grep -E "Config|EP_SSB" |  tr "\n" " "`

stage=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "echo '. \\${HOME}/.profile \n tostage \n pwd ' > /tmp/drst.sh ; /usr/bin/ksh /tmp/drst.sh ; rm /tmp/drst.sh"`
echo " STAGING PATH = ${stage} \n"

echo " COPYING FILES ${file2scp}  to ${stage} \n"

echo "scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/UOBsubprgm_pass3.ksh ${usrid}@${dmgr}:${stage}/"
scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/UOBsubprgm_pass3.ksh ${usrid}@${dmgr}:${stage}/
#scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${cwd}/UOBsubprgm_pass3.ksh ${usrid}@${dmgr}:${stage}/

###### Execute build on DMGR

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Executing Build on DMGR ${srvr_nm} (${dmgr})         +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#srvr_nm=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "hostname"`
echo "ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} \"chmod 755 ${stage}/UOBsubprgm_pass3.ksh ; ${stage}/UOBsubprgm_pass3.ksh ${pkg_ver} ${fiid} ; rm ${stage}/UOBsubprgm_pass3.ksh\""
ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "chmod 755 ${stage}/UOBsubprgm_pass3.ksh ; ${stage}/UOBsubprgm_pass3.ksh ${pkg_ver} ${fiid} ; rm ${stage}/UOBsubprgm_pass3.ksh"
success_code=$?

case $success_code in
	0) echo " Build Deployment is Success" ;;
	1) echo " Build Deployment Failed at Link Creation" ;;
	2) echo " Build Deployment Failed at Deploy Step " ;;
	3) echo " Build Deployment Failed at Install Step " ;;
	4) echo " Build Deployment Failed at Stopping Application " ;;
	5) echo " Build Deployment Failed at Starting Application " ;;
	*)  echo " Build Deployment Failed Unknown Reason " ;;

esac

if [ ${success_code} -eq 0 ]
then
	echo "\nBuild deployed Successfully for ${fiid}"
	echo "Check email for details"
else

	echo "Build deployed failed for ${fiid}"
fi
#echo " Check mail to verify the changes and then run Pass3 "
exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/out.pipe

echo "${dt},${pkg_ver},${srvr_nm},${dmgr}" >> ${pkgpath}/audit_blddtl
echo "${dt}" >> ${pkgpath}/old_blddtl


##### Composing love letter

srvr=`awk -F":" '/Server Name/ {print $2}' ${logfile}`
echo "All,\nNew EAR/JAR has been deployed on ${fiid}(${srvr}) as per the request.\n" > ${logpath}/rndnum
echo "Environemnt is up and available for testing. Please respond within 24 hours that you have reviewed the environment and fixes." >> ${logpath}/rndnum
echo "Report deployment related issues(if any) encountered during testing.\n" >> ${logpath}/rndnum

echo "New EAR/JAR Details:" >> ${logpath}/rndnum
echo "--------------------" >> ${logpath}/rndnum

echo "EAR : " `awk -F":" '/New_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "JAR : " `awk -F":" '/New_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "\n\n"  >> ${logpath}/rndnum

echo "The following EAR/JAR is available for back out purpose located at (/platform/${fiid}/Stage):" >> ${logpath}/rndnum

echo "EAR : " `awk -F":" '/Old_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "JAR : " `awk -F":" '/Old_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum

#echo "You can find build details on wiki page at: http://wiki.s1.com/display/dev/Hosting " >> ${logpath}/rndnum

#echo "Your Slave,\nDMS System" >> ${logpath}/rndnum

mail -r "dmsbuild@bankonline.com"  -s "Build Update for ${fiid}" "EPOperationsSystemEngandAdminTeam@aciworldwide.com,pune-hosting-app@aciworldwide.com" < ${logpath}/rndnum

##### My job is done where is my money!!!!

exit 0

