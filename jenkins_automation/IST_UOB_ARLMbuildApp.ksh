#!/usr/bin/ksh

if [ $# -ne 2 ]
then
    # if  bankenv not passed, send error and exit
    echo "Usage: $0 <FIID> <IST INSTANCE>"
    echo "Example: $0 fisq1 issq1"
    exit 1
fi

fiid=$1
istusr=$2

echo "--------------------------------------------------------------------------------"
echo "Starting a new IST build for Bank ${fiid} with IST instance $istusr"

sudo su - $istusr -c "arlm buildApp -Dbuild.task=build-all -Denv.name=${fiid}" 2>/dev/null
if [ $? -eq 0 ]
then
 echo "--------------------------------------"
 echo "IST Build for Bank ${fiid}: SUCCESS"
 echo "--------------------------------------"
else
 echo "--------------------------------------"
 echo "IST Build for Bank ${fiid}: FAILED"
 echo "--------------------------------------"
fi

exit 0
