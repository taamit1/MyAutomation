#!/bin/ksh
ADMUSER="dmsadm"
ADMUSER_HOME="/platform/$ADMUSER"

PRODNAME="Banking"
if test ! -d $HOME/s1env/EP/$PRODNAME
then
  PRODNAME="CorporateBanking"          # if not Banking try to use CorporateBanking
  if test ! -d $HOME/s1env/EP/$PRODNAME
  then
    PRODNAME="CBInternational"          # if not Banking try to use CorporateBanking
    if test ! -d $HOME/s1env/EP/$PRODNAME
    then
      PRODNAME="TradeFinance"          # if not CorporateBanking try to use TradeFinance
      if test ! -d $HOME/s1env/EP/$PRODNAME
      then
        PRODNAME="NAO"          # if not TradeFinance try to use NAO
      fi
    fi
  fi
fi

S1ANTHOME1="$HOME/s1env/EP/build/$PRODNAME/S1-INSTALL-INF"
S1ANTHOME2="$HOME/s1env/EP"
S1BLDHOME="$HOME/s1env/EP/build"
S1CUSTHOME="$HOME/s1env/EP/$PRODNAME"
S1BLDHOST=`hostname`

LOGFILE="${ADMUSER_HOME}/${ADMUSER}.log"
#FINAME=`echo $LOGNAME|sed -e "s/dms/fi/"`
FINAME=`echo $LOGNAME|sed -e "s/^dms/fi/" |sed -e "s/^dm/fi/"`
LOGINUSER=`who am i |cut -f1 -d' '`

if [ -f ${ADMUSER_HOME}/sqllib/db2profile ]; then
    . ${ADMUSER_HOME}/sqllib/db2profile
fi

export PATH=$PATH:/support/bin/apache-ant-1.7.0/bin:/usr/local/bin


# keep just last 5 ear/jar files
PURGE_VERS=5
cd $S1BLDHOME
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
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      rm -f $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Config/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      rm -f $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Actuate/" -e "s/log$/jar/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      rm -f $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/EP/" -e "s/log$/ear/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      rm -f $ONAM $NNAM
      ONAM=`echo $NAM |sed -e "s/^Build/Patch/" -e "s/log$/rpt/"`
      NNAM=`echo $ONAM |sed -e "s/_SSB//"`
      rm -f $ONAM $NNAM
    fi
  done
fi

