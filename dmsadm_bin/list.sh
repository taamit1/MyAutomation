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
PURGE_VERS=2
cd $BLDHOME
if test $? -eq 0
then
  echo "\nCleaning up old ear/jar files in `pwd`:"
  CNT=0
  for NAM in `ls -t Build_SSB_*_${FINAME}.log`
  do
    CNT=$(($CNT + 1))
    if test $CNT -gt $PURGE_VERS
    then
      echo "Removing all $NAM related files ..."
      rm -f $NAM
      ONAM=`echo $NAM |sed -e "s/^Build/DB/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB/_DB2/"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Config/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/EP/" -e "s/log$/ear/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Patch/" -e "s/log$/rpt/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Actuate/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Static/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Custom_Patch/" -e "s/log$/rpt/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      echo $ONAM $NNAM
    fi
  done
fi

#
# EOS
#
