#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/platform/${fiid}"
pkgpath="/packages/${fiid}"
svnpath="${srcpath}/EP/Banking"

cd ${svnpath}

# Running Actual Build
echo "-------------------------------------------------------------------"
echo "Checking files Added/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAntUB.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="y"/g' /tmp/uA${random}
/tmp/uA${random} build-all
echo "-------------------------------------------------------------------"
rm /tmp/uA${random}
exit 0
