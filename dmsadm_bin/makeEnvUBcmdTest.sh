#
# makeEnv.sh
#
if [ $# -ne 1 ]
then
        # if corerelver not passed, send error and exit
        echo " Usage: $0 <corerelver>"
        echo " Example: $0 UB5.1.1.4H0"
        exit 1
fi

crelver=$1

ADMUSER="dmsadm"
REPO_ROOT="/dms"

PATH=$PATH:/usr/local/bin

EP_VER_FILE="$HOME/.ep_ver"
EP_VAL_FILE=/platform/$ADMUSER/bin/makeEnv.dat

LOGFILE="/platform/$ADMUSER/$ADMUSER.log"
FINAME=`lsuser -a home $LOGNAME | awk -F '/' {'print $3'}`
LOGINUSER=`who am i |cut -f1 -d' '`

#
# SVN tasks
#
umask 002
SVN_CREATED="N"

groups | grep "svngrp" >>/dev/null 2>&1
if test $? -ne 0
then
  echo "Error: This user must belong to the svngrp group before continuing."
  echo "       Contact an AIX administrator to have this user added to svngrp group"
  exit 2
fi

####
# BASE version setup
####

PRODBASE="UB5.1"
PRODNAME="UOB"
SVCPDESC="Refresh"
SVCPDEF="0"
FIXPDEF="0"

#
# gather env version
#
echo "Current Application version selected: $PRODBASE"

#
# get Release version?
#
PRODSVCP=`echo $crelver|awk -F'.' '{print $3}'`
[ -z "$PRODSVCP" ] && PRODSVCP="$SVCPDEF"

#
# get Fixpack version?
#
PRODFIXP=`echo $crelver|awk -F'H' '{print $1}'|awk -F'.' '{print $4}'`
[ -z "$PRODFIXP" ] && PRODFIXP="$FIXPDEF"

#
# get HotFix version?
#
PRODHOTF=`echo $crelver|awk -F'H' '{print $2}'`
[ -z "$PRODHOTF" ] && PRODHOTF="0"

EP_VER="${PRODBASE}.${PRODSVCP}.${PRODFIXP}H${PRODHOTF}"

PRODDIR="/platform/$EP_VER"

echo "Core REL to upgrade to $EP_VER for $FINAME"

