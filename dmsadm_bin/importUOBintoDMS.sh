#!/bin/ksh

#####
# Script to import CORE UOB version in DMS (epdms01) without SVN import
#####

## Variables ##

DATE=`date +%b_%d_%Y_%T`
EP_VER_FILE="$HOME/.ep_ver"

if test $USER != "dmsadm"
then
  echo
  echo "Must be run as dmsadm!"
  echo
  exit 1
fi

if test $# -ne 1
then
  echo
  echo "USAGE: `basename $0` <EP Version e.g. EP3.7.0.0H0>"
  echo
  exit
else
  EP_VER=$1
fi

mkdir -p "$HOME/../$EP_VER"
if test $? -ne 0
  then
    echo "ERROR: could not create directory $INST_WORKLOC"
    exit 1
 fi

echo "Core FILE to be imported e.g. /tmp/RETAIL_GA_3.7.R3.0-DMS"
read CORE_FILE

if test ! -f ${CORE_FILE}
then
   echo "Can't read ${CORE_ZIP} file to be imported"
   exit 1
else
   unzip ${CORE_FILE}.zip
fi

cd ${CORE_FILE}

INST_LOCATION="$HOME/../$EP_VER"
INST_WORKLOC="${CORE_ZIP}"

rm -rf $INST_WORKLOC
if test ! -d $INST_WORKLOC
then
  mkdir -p $INST_WORKLOC
  if test $? -ne 0
  then
    echo "ERROR: could not create directory $INST_WORKLOC"
    exit 1
  fi
fi

cd $INST_WORKLOC
if test $? -ne 0
then
  echo "ERROR: could not cd to directory $INST_WORKLOC"
  echo "Did not extract updates, could not find $INST_LOCATION"
  exit 2
else
  mkdir Banking Actuate
  cd Banking
    jar xf ${CORE_ZIP}
    echo "Importing CORE JAR file..."
    rsync -cr $INST_WORKLOC/Banking/ ./

    mv product
fi

rm -rf $INST_WORKLOC

chmod -R 775 "$HOME/../$EP_VER"

exit 0
