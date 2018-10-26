#!/usr/bin/ksh

##### Function Starts Here

extract_jar ()
{
  rm -rf INSTALL-INF UOB META-INF >/dev/null 2>&1
  jar -xf $dbjar 2>&1

}

deploy_db ()
{
	arlm DBinstall -Ddb.target=$dbtarget -Denv.name=$fiid -Ddb.user=$dbid -Ddb.pass=$dbpass
	if [ $? -eq 0 ]
	then
		echo "------------------------------------------------------"
		echo "DB install :  SUCCESS "
		echo "------------------------------------------------------"
	else
		echo "------------------------------------------------------"
		echo "DB install :  FAILED "
		echo "------------------------------------------------------"
		exit 1
	fi
}

cleanup_old ()
{
    # keep just last 3 ear/jar files
    echo "Cleaning up old DB JARs in `pwd`:"
    ls -t|grep -E DB.*jar|awk 'NR>4'|xargs rm -f
}

## Main Starts Here

dbjar=$1
fiid=$2
dbid=$3
dbpass=$4
dbtarget=$5
dt=`date +"%d%b%Y%H%M%S"`
export FINAME=$fiid

echo "DB JAR Version is:$dbjar for $FINAME"
echo "DB Server Name:"`hostname`
. ${HOME}/.profile >/dev/null 2>&1

#Check DB process is active or not
#check_dbprocess

cd /platform/${fiid}/EP
if [ $? -eq 0 ]
then
	cwd=`pwd`
	echo "Current Directory on DB server : ${cwd} \n"
	echo "Extracting DB JAR on DB servers...\n"
	extract_jar
	echo "Forcing application connections...\n"
	echo "------------------------------------------------------"
	deploy_db
    	sleep 10
	cleanup_old
else
	echo "PROBLEM IMPORTING USER PROFILE "
	exit 7
fi

exit 0
