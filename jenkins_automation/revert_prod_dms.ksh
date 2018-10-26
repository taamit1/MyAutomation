#!/usr/bin/ksh
if [ $# -ne 3 ]
  then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID> <VBuildToRevert> <DMS User>"
        echo " Example: $0 fisq1 UB5.1.2.1H0V32 dms71023"
        exit 1
fi

cwd="/packages/automation"
FIID=$1
VBUILD=$2
dmsusr=$3
srcpath="/platform/${FIID}"
EP_VER_FILE="${srcpath}/.ep_ver"

EP_VER_NEW=`echo $VBUILD|awk -F'V' '{print $1}'`
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'V' '{print $1}'`

if [ $EP_VER_NEW != $EP_VER_CUR ]
then
   date
   echo
   echo "###########################################################################"
   echo "# ERROR: DMS instance $dmsusr is not at $EP_VER_NEW level...              #"
   echo "# Use DMS script makeEnv.sh or makeEnvUB.sh to revert back to $EP_VER_NEW #"
   echo "###########################################################################"
   echo
   exit 1
else
  echo "-------------------------------------------------------------------------"
  date
  echo "Reverting back DMS instance $dmsusr to $VBUILD..."
  echo "-------------------------------------------------------------------------"
  echo "Current DMS version is shown below..."
fi

PRODNAME="Banking"
if test ! -d ${srcpath}/s1env/EP/$PRODNAME
then
  PRODNAME="CorporateBanking"          # if not Banking try to use CorporateBanking
  if test ! -d ${srcpath}/s1env/EP/$PRODNAME
  then
    PRODNAME="CBInternational"          # if not Banking try to use CorporateBanking
    if test ! -d ${srcpath}/s1env/EP/$PRODNAME
    then
      PRODNAME="TradeFinance"          # if not CorporateBanking try to use TradeFinance
      if test ! -d ${srcpath}/s1env/EP/$PRODNAME
      then
        PRODNAME="NAO"          # if not TradeFinance try to use NAO
        if test ! -d ${srcpath}/EP/$PRODNAME
        then
          PRODNAME="UOB"          # if not NAO try to use UOB
       fi
      fi
    fi
  fi
fi

svnpath="${srcpath}/s1env/EP/${PRODNAME}"
uobsvnpath="${srcpath}/EP/${PRODNAME}"
idfi=`echo ${FIID#??}`
dt=`date +"%d%b%Y%H%M%S"`
dt1=`date +"%d-%b-%Y"`
pkgpath="/packages/${FIID}"
logpath="${pkgpath}/${dt}"
logfile="${logpath}/revert_prod_pass1.log"
mkdir ${logpath}
echo

## This is for logging intelegance
mkfifo ${logpath}/out.pipe
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/out.pipe >&3 &
pid_out=$!
exec  1>${logpath}/out.pipe
exec  2>${logpath}/out.pipe

## Running the subprogram for actual revert back
sudo su - $dmsusr -c "${cwd}/revert_subprgm.ksh ${FIID} ${VBUILD} ${PRODNAME} ${svnpath} ${uobsvnpath} ${dt}" 2>/dev/null

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/out.pipe
date

## Composing build mail
echo "\nCheck email to verify the changes and run build jobs Pass1 and Pass2 for new reverted build...\n"
echo "Hello,\nPlease verify the delta list to revert back ${dmsusr} of ${FIID} to ${VBUILD}.\n" > ${logpath}/tmp
echo "Revert back date : "`date +"%d-%b-%Y"`"\n" >> ${logpath}/tmp
awk -F":" '/SVN has found/ {print "Build evaluation : "$2}' ${logfile} >> ${logpath}/tmp
echo "\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##  Files Modified  ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^[mM]/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##   Files Added    ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^\?/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##  Files Deleted   ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^\!/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n\n" >> ${logpath}/tmp

mail -r "dmsbuild@bankonline.com"  -s "Revert back verification for ${dmsusr} to ${VBUILD} for ${FIID}" amit.tarwade@aciworldwide.com < ${logpath}/tmp
rm ${logpath}/tmp

exit 0
