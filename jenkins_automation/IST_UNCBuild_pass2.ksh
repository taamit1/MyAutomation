#!/usr/bin/ksh

if [ $# -ne 3 ]
then
    # if  bankenv not passed, send error and exit
    echo " Usage: $0 <FIID> <App. USER ID> <DMGRi EXT IP>"
    echo " Example: $0 fi9999 usrXXXX 172.30.4.X"
    exit 1
fi

cwd="/packages/automation"
fiid=$1
usrid=$2
dmgr=$3
idfi=`echo ${fiid#??}`
rndnum=`date +"%H%M%S"`
dt1=`date +"%d-%b-%Y"`

dmgr_host=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "hostname"`
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/istblddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/deploy_ist_${dmgr}.log"

#### Checking if script is run by mistake
if [ ! -f ${pkgpath}/istblddtl ] || [ ! -f ${logpath}/build_pass1.log ]
then
        echo "\nERROR: There are no build details available for now ...."
        echo "You seem to have run this job by mistake ....\n "
        echo "Execute Pass1 IST job for build before running the deploy job .... \n"
        echo "Exiting ...................................................\n"
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

echo "---------------------------------------------------------"
date;echo

#### Identifying which packages to push
pkg_ver=`awk -F"EP|CI|CB|TO|NA|UB|OB" '/Build/ {gsub(/\./,"");print $2}' ${logpath}/build_pass1.log| head -1| awk -F"for" '{print $1}'`
grep $pkg_ver ${logpath}/build_pass1.log|awk -F":" '{print $2}' | sort | uniq > ${logpath}/pkg_info

#### Copying packages to DMGR
file2scp=`grep -E "Config|build/EP" ${logpath}/pkg_info | tr "\n" " "`

stage=`ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "echo '. \\${HOME}/.profile >/dev/null 2>&1 \n tostage \n pwd ' > /tmp/drst.sh ; /usr/bin/ksh /tmp/drst.sh ; rm /tmp/drst.sh"`
echo " STAGING PATH = ${stage} \n"
echo " COPYING FILES ${file2scp}  to ${stage} \n"
scp  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${file2scp} ${cwd}/IST_UNCsubprgm_pass2.ksh ${usrid}@${dmgr}:${stage}/

echo "##########################################################"
echo "# Starting deployment of new build on DMGR ${dmgr_host}  #"
echo "##########################################################"
ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "chmod 755 ${stage}/IST_UNCsubprgm_pass2.ksh ; ${stage}/IST_UNCsubprgm_pass2.ksh ${pkg_ver} ${fiid}"
success_code=$?
case $success_code in
        0) echo " " ;;
        1) echo " " ;;
        2) echo "\nERROR: Build Deployment Failed at Link Creation" ;;
        3) echo "\nERROR: Build Deployment Failed at Deploy Step " ;;
        4) echo "\nERROR: Build Deployment Failed at Install Step " ;;
        5) echo "\nERROR: Build Deployment Failed at Stopping Application " ;;
        6) echo "\nERROR: Build Deployment Failed at Starting Application " ;;
        *) echo "\nERROR: Build Deployment Failed with unknown reasons " ;;
esac

echo "------------------------------------------------------"

if [ ${success_code} -eq 0 ]
then
  echo "\nBuild deployed Successfully for ${fiid}"
  ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/IST_UNCsubprgm_pass2.ksh"
  echo "Check email for details"
  echo "---------------------------------------------------"
  date;echo
else
  echo "Build deployed failed for ${fiid}"
  ssh  -o StrictHostKeyChecking=no -i ${cwd}/.ssh/build-key ${usrid}@${dmgr} "rm ${stage}/IST_UNCsubprgm_pass2.ksh"
  echo "---------------------------------------------------"
  date;echo
  exit 1
fi

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/$dtout

##### Composing build email
srvr=`awk -F":" '/Server Name/ {print $2}' ${logfile}`
echo "All,\nThe deployment of the following new EAR/JAR has been completed on SPECIFY BANK/ENV HERE (${srvr}). Server is up and available for testing." > ${logpath}/rndnum
echo "Please respond within 24 hours that you have reviewed the environment and fixes. Provide any issues encountered during testing.\n" >> ${logpath}/rndnum

echo "       " `awk -F":" '/New_EAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "       " `awk -F":" '/New_JAR :/ {print $2}' ${logfile}` >> ${logpath}/rndnum
echo "\n"  >> ${logpath}/rndnum

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
mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" Ronald.Henry@aciworldwide.com < ${logpath}/rndnum
mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" amit.tarwade@aciworldwide.com < ${logpath}/rndnum
mail -r "dmsbuild@bankonline.com"  -s "Deployment Completed for ${fiid} on app server ${srvr}" pallavi.kulkarni@aciworldwide.com < ${logpath}/rndnum

exit 0
