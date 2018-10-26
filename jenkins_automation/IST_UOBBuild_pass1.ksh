#!/usr/bin/ksh

if [ $# -ne 2 ]
then
     # if  bankenv not passed, send error and exit
     echo " Usage: $0 <FIID> <DMSUSER>"
     echo " Example: $0 fi9999 is9999"
     exit 1
fi

cwd="/packages/automation"
fiid=$1
dmsusr=$2
idfi=`echo ${fiid#??}`
dt=`date +"%d%b%Y%H%M%S"`
dt1=`date +"%d-%b-%Y"`

pkgpath="/packages/${fiid}"
logpath="${pkgpath}/${dt}"
logfile="${logpath}/ist_build_pass1.log"

srcpath="/istplatform/${fiid}"
EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'T' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
corebuildfile="${corepath}/EP/UOB/INSTALL-INF/build.properties"
patchpath="${corepath}/EP/UOB/patch"

# check if core patch folder is writable for dmsusr
if ls -ld ${patchpath}|grep -q ^drwxrwxr-x >/dev/null 2>&1
then
  chmod -R 775 ${patchpath} >/dev/null 2>&1
else
  chmod -R 775 ${patchpath} >/dev/null 2>&1
fi

echo "------------------------------------------------------"
date;echo

## Checking if core build.properties contains s1env
grep "s1env" ${corebuildfile} >/dev/null 2>&1
if [ $? -eq 0 ]
then
   echo
   echo "########################################################################################"
   echo "# The ${corebuildfile} looks incorrect                                                 #"
   echo "# Remove s1env from ${corebuildfile}                                                   #"
   echo "# by login as dmsadm on epdms01 and try this build Job again.                          #"
   echo "# Exiting .......................................                                      #"
   echo "########################################################################################"
   echo
   exit 1
fi

## Checking if build is triggered by mistake
if [ ! -f ${pkgpath}/*.zip ]
then
        echo
        echo "************************************************************************"
        echo "WARNING: There is no custom zip package found under /packages/${fiid}   "
        echo "So CONTINUING without the custom package for ${fiid}...                 "
        echo "You can run Pass2 job to create EAR/JAR without new custom build...     "
        echo "************************************************************************"
        #exit 0
fi

mkdir ${logpath}
echo ${dt} > ${pkgpath}/istblddtl
#echo ${dmgr_node} > ${logpath}/dmgr

## This is for logging intelegance
mkfifo ${logpath}/out.pipe
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/out.pipe >&3 &
pid_out=$!
exec  1>${logpath}/out.pipe
exec  2>${logpath}/out.pipe

chown -R ${dmsusr}.staff ${logpath} >/dev/null 2>&1
chown ${dmsusr}.staff *.* >/dev/null 2>&1

PKGCNT=`ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|wc -l`
if [ ${PKGCNT} -gt 6 ]
then
  echo "Removing old DIRs from Package Upload DIR..."
  ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|xargs rm -rf 2>/dev/null
fi

echo "------------------------------------------------------"
sudo su - $dmsusr -c " ${cwd}/IST_UOBsubprgm_pass1.ksh ${fiid} ${dt}" 2>/dev/null

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/out.pipe

## Get latest version info
buildApp_log=`grep "Recording" ${logpath}/ist_build_pass1.log |grep buildApp|uniq|awk -F"at" '{print $2}'|awk -F" " '{print $1}'`
pkg_ver=`awk -F"UB|EB|OB|EP" '/FI_BLD_VER/ {print $2}' $buildApp_log|awk -F"\'" '{print $1}'`
grep $pkg_ver $buildApp_log|egrep '.jar|.ear'|grep -v "static-content"|awk -F":" '{print $2}' | sort | uniq > ${logpath}/pkg_info

patch_rpt="${srcpath}/EP/build/Patch_UB${pkg_ver}_${fiid}.rpt"
totalpatch=`grep "GBS-..... -" $patch_rpt|wc -l` >/dev/null 2>&1

egrep "BUILD FAILED|ERROR:|\*ERROR\*" ${logfile} >/dev/null 2>&1
if [ $? -eq 0 ]
then
        echo "BUILD FAILED, please check for ERROR in the build logs on DMS"
	echo "-------------------------------------------------------------------"
	date
        echo "-------------------------------------------------------------------"
	exit 1
else
	echo "-------------------------------------------------------------------"
	echo "Total Applied Core patches in this build are :$totalpatch \n"
	grep "GBS-..... -" $patch_rpt 2>&1
	echo "-------------------------------------------------------------------"

	echo "Check above build logs and below build artifacts and then run required deploy jobs...\n"
	echo "New Build artifacts are shown below...\n"
	cat ${logpath}/pkg_info 2>&1
	echo "-------------------------------------------------------------------"
	date
	echo "-------------------------------------------------------------------"
fi

