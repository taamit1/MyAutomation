#!/usr/bin/ksh
if [ $# -ne 3 ]
then
     #if correct parameters are not passed, send error and exit
     echo " Usage: $0 <FIID> <VBuildToSync> <IST instance>"
     echo " Example: $0 fi71023 EP3.7.4.3H0V32 ist71023"
     exit 1
fi

cwd="/packages/automation"
FIID=$1
VBUILD=$2
istusr=$3
istpath="/istplatform/${FIID}"
EP_VER_FILE="${istpath}/.ep_ver"

VCORE=`echo $VBUILD|awk -F'V' '{print $1}'`
TCORE=`tail -1 $EP_VER_FILE|awk -F' ' '{print $2}'|awk -F'T' '{print $1}'`

if [ $VCORE != $TCORE ]
then
   echo "########################################################"
   echo "ERROR: IST instance $istusr is not at $VCORE level...   "
   echo "It is currently at $TCORE level...			 "
   echo "Upgrade $istusr to $VCORE and then try this job again..."
   echo "########################################################"
   exit 1
else
  echo "-----------------------------------------"
  echo "Starting the sync for $istusr...\n"
fi

PRODNAME="Banking"
if test ! -d ${istpath}/s1env/EP/$PRODNAME
then
  PRODNAME="CorporateBanking"          # if not Banking try to use CorporateBanking
  if test ! -d ${istpath}/s1env/EP/$PRODNAME
  then
    PRODNAME="CBInternational"          # if not Banking try to use CorporateBanking
    if test ! -d ${istpath}/s1env/EP/$PRODNAME
    then
      PRODNAME="TradeFinance"          # if not CorporateBanking try to use TradeFinance
      if test ! -d ${istpath}/s1env/EP/$PRODNAME
      then
        PRODNAME="NAO"          # if not TradeFinance try to use NAO
        if test ! -d ${istpath}/EP/$PRODNAME
        then
          PRODNAME="UOB"          # if not NAO try to use UOB
       fi
      fi
    fi
  fi
fi

islocpath="${istpath}/s1env/EP/${PRODNAME}"
isuobpath="${istpath}/EP/${PRODNAME}"

idfi=`echo ${FIID#??}`
dt=`date +"%d%b%Y%H%M%S"`
dt1=`date +"%d-%b-%Y"`
pkgpath="/packages/${FIID}"
logpath="${pkgpath}/${dt}"
logfile="${logpath}/sync_ist_instance.log"
mkdir ${logpath}
echo

##### This is for logging intelegance
mkfifo ${logpath}/out.pipe
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/out.pipe >&3 &
pid_out=$!
exec  1>${logpath}/out.pipe
exec  2>${logpath}/out.pipe

## Running the subprogram for sync up
sudo su - $istusr -c "${cwd}/sync_ist_subprgm.ksh ${FIID} ${VBUILD} ${PRODNAME} ${islocpath} ${isuobpath} ${dt}" >/dev/null 2>&1

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/out.pipe

echo "\nSyncing IST instance $istusr with ${VBUILD} for ${FIID} is complete, run IST build job Pass1 for new build...\n"

exit 0
