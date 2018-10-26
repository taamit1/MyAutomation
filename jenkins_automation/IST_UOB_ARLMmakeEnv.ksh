#!/usr/bin/ksh

if [ $# -ne 3 ]
then
    # if  bankenv not passed, send error and exit
    echo "Usage: $0 <CORE_REL> <FIID> <IST INSTANCE>"
    echo "Example: $0 UB5.1.1.4H0 fisq1 issq1"
    exit 1
fi

corerelver=$1
fiid=$2
dmsusr=$3

echo "--------------------------------------------------------------------------------"
echo "Upgrading IST instance ${dmsusr} for Bank ${fiid}  to Core Release ${corerelver}"
sleep 20

sudo su - $dmsusr -c "arlm makeAppEnv -Drelease.version=${corerelver} -Denv.name=${fiid}"
if [ $? -eq 0 ]
then
 echo "###############################################################################################"
 echo "Upgrade to Core Release ${corerelver} for IST instance ${dmsusr} of Bank ${fiid} is : SUCCESS"
 echo "New version details are as shown below"
 echo "###############################################################################################"
 sudo su - $dmsusr 2>/dev/null
else
 echo "###############################################################################################"
 echo "Upgrade to Core Release ${corerelver}: FAILED"
 echo "Check above error in console log or on DMS"
 echo "###############################################################################################"
 exit 1
fi

echo "--------------------------------------"
exit 0
