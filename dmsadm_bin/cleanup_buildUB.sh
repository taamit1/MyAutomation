#!/bin/ksh
ADMUSER="dmsadm"
ADMUSER_HOME="/platform/$ADMUSER"
ARLM_BIN="/support/bin615"

PRODNAME="UOB"
if test ! -d $HOME/EP/$PRODNAME
then
  PRODNAME="EBDCOS"          # if not UOB try to use OB
   if test ! -d $HOME/EP/$PRODNAME
   then
      PRODNAME="Banking"          # if not OB try to use EB
   fi
fi

ANTHOME1="$HOME/EP/build/$PRODNAME/INSTALL-INF"
ANTHOME2="$HOME/EP"
BLDHOME="$HOME/EP/build"
CUSTHOME="$HOME/EP/$PRODNAME"
BLDHOST=`hostname`

LOGFILE="${ADMUSER_HOME}/${ADMUSER}.log"
#FINAME=`echo $LOGNAME|sed -e "s/dms/fi/"`
FINAME=`lsuser -a home $LOGNAME | awk -F '/' {'print $3'}`
LOGINUSER=`who am i |cut -f1 -d' '`

if [ -f ${ADMUSER_HOME}/sqllib/db2profile ]; then
    . ${ADMUSER_HOME}/sqllib/db2profile
fi

export PATH=$PATH:$ARLM_BIN/apache-ant/bin:/usr/local/bin

# keep just last 3 ear/jar files
PURGE_VERS=3
cd $BLDHOME
if test $? -eq 0
then
  echo "\nKeeping just last 3 build files, Cleaning up old artifacts in `pwd`:\n"

  echo "Cleaning old EARs...\n"
  ls -t|grep -E EP.*ear|awk 'NR>3'|xargs rm -f

  echo "Cleaning old JARs...\n"
  ls -t|grep -E Config.*jar|awk 'NR>3'|xargs rm -f
  ls -t|grep -E DB.*jar|awk 'NR>3'|xargs rm -f
  ls -t|grep -E Static.*jar|awk 'NR>3'|xargs rm -f
  ls -t|grep -E Actuate.*jar|awk 'NR>3'|xargs rm -f

  echo "Cleaning old log and rpt files...\n"
  ls -t|grep -E Build.*log|awk 'NR>3'|xargs rm -f
  ls -t|grep -E Patch.*rpt |awk 'NR>3'|xargs rm -f

fi

#
# EOS
#
