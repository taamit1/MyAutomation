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
        PRODNAME="NAO"          	# if not TradeFinance try to use NAO
        if test ! -d $HOME/s1env/EP/$PRODNAME
        then
          PRODNAME="UOB"
          echo "Looks like you're building for UOB/EB..."
          echo
          echo "So use useAntUB.sh script for UOB/EB builds."
          echo
          exit 1
       fi
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

export PATH=$PATH:/support/bin/apache-ant-1.8.2/bin:/usr/local/bin

# keep just last 3 ear/jar files
PURGE_VERS=3
cd $S1BLDHOME
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
  ls -t|grep -E Birt.*jar|awk 'NR>3'|xargs rm -f

  echo "Cleaning old log and rpt files...\n"
  ls -t|grep -E Build.*log|awk 'NR>3'|xargs rm -f
  ls -t|grep -E Patch.*rpt |awk 'NR>3'|xargs rm -f

fi

#
# EOS
#
