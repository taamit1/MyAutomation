#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/platform/${fiid}"
pkgpath="/packages/${fiid}"

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
        if test ! -d ${srcpath}/s1env/EP/$PRODNAME
        then
          PRODNAME="UOB"
          echo "You're building for UOB/EB."
          echo ""
          echo "So please use UOB build scripts for UOB/EB builds."
          echo ""
          exit 1
       fi
      fi
    fi
  fi
fi

svnpath="${srcpath}/s1env/EP/${PRODNAME}"
cd ${svnpath}

### Running Actual Build
echo "-------------------------------------------------------------------"
echo "Checking File Added/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="y"/g' /tmp/uA${random}
/tmp/uA${random} build-all
echo "-------------------------------------------------------------------"
rm /tmp/uA${random}
exit 0
