#!/usr/bin/ksh

if [ $# -ne 3 ]
then
    # if  bankenv not passed, send error and exit
    echo "Usage: $0 <CORE_REL> <FIID> <DMS INSTANCE>"
    echo "Example: $0 UB5.1.1.4H0 fisq1 dmsq1"
    exit 1
fi

corerelver=$1
fiid=$2
dmsusr=$3

echo "--------------------------------------------------------------------------------"
echo "Upgrading DMS instance ${dmsusr} for Bank ${fiid}  to Core Release ${corerelver}"

sudo su - $dmsusr -c "makeEnvUBcmd.sh ${corerelver}" 2>/dev/null
if [ $? -eq 0 ]
then
 echo "###############################################################################################"
 echo "Upgrade to Core Release ${corerelver} for IST instance ${dmsusr} of Bank ${fiid} is : SUCCESS"
 echo "New version details are as shown below"
 echo "###############################################################################################"
 sudo su - $dmsusr 2>/dev/null
else
 echo "Upgrade to Core Release ${corerelver}: FAILED"
 exit 1
fi

echo "--------------------------------------"
exit 0
