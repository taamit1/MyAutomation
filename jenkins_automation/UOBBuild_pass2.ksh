#!/usr/bin/ksh

if [ $# -ne 2 ]
then
    # if  bankenv not passed, send error and exit
    echo " Usage: $0 <FIID>  <DMSUSER>"
    echo " Example: $0 fi9999 dms9999"
    exit 1
fi

cwd="/packages/automation"
fiid=$1
dmsusr=$2

srcpath="/platform/${fiid}"
EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'V' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
corebuildfile="${corepath}/EP/UOB/INSTALL-INF/build.properties"

pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_pass2.log"

echo "-------------------------------------------------------------------"
date

## Checking if script is run by mistake
if [ ! -f ${pkgpath}/blddtl ]
then
  echo
  echo "There is no build detail available for now ...."
  echo "You seem to have run the script by mistake ...."
  echo "Execute Pass1 before running Pass2 ...."
  echo "Exiting ......................................."
  echo
  exit 1
fi

## Checking if core build.properties contains s1env
grep "s1env" ${corebuildfile} >/dev/null 2>&1
if [ $? -eq 0 ]
then
   echo
   echo "########################################################################################"
   echo "# The ${corebuildfile} looks incorrect                                         	#"
   echo "# Remove s1env from ${corebuildfile}                                                   #"
   echo "# by login as dmsadm on epdms01 and try this build Job again.                          #"
   echo "# Exiting .......................................                                      #"
   echo "########################################################################################"
   echo
   exit 1
fi

## This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/$dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/$dtout >&3 &
pid_out=$!
exec  1>${logpath}/$dtout
exec  2>${logpath}/$dtout

sudo su - $dmsusr -c " ${cwd}/UOBsubprgm_pass2.ksh ${fiid} ${dt}" 2>/dev/null

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/$dtout

## Logging New Package to details
## Get latest version info
pkg_ver=`awk -F"UB|EB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`
awk -F":" -v ss="${pkg_ver}" '$0 ~ ss {print $2}' ${logpath}/build_pass2.log | sort | uniq | grep -v "into"  > ${logpath}/pkg_info

patch_rpt="${srcpath}/EP/build/Patch_UB${pkg_ver}_${fiid}.rpt"

if [ -f ${patch_rpt} ]
then
  totalpatch=`grep "GBS-...... -" $patch_rpt|wc -l` 2>&1
  echo "Total Applied Core patches in this build are :$totalpatch \n"
  grep "GBS-...... -" $patch_rpt 2>&1
  echo "-------------------------------------------------------------------"
fi

egrep "BUILD FAILED|ERROR:|\*ERROR\*" ${logfile} >/dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "BUILD FAILED, please check for ERROR in the build logs on DMS"
  exit 1
else
  echo "Check above build logs and below build artifacts and then run required deploy jobs...\n"
  echo "New Build artifacts are shown below...\n"
  cat ${logpath}/pkg_info 2>&1
  echo "-------------------------------------------------------------------"
  exit 0
fi
