#!/usr/bin/ksh

##### Function Starts Here
copy_pkg
{
        jar -xf /tmp/$file2scp >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo " Static Content Copy :  SUCCESS \n"
	else
		echo " Static Content Copy :  FAILED \n"
		exit 2
	fi
}

##################Main Starts Here

file2scp=$1
statpath=$2

echo "$file2scp $statpath"
echo "Server Name:"`hostname`
. ${HOME}/.profile

tostat
if [ $? -eq 0 ]
then
	cd /opt/static_content/media/$statpath/static-content
		if [ $? -eq 0 ]
 		then
			cwd=`pwd`
			echo " Current Directory on Web: ${cwd} \n"
			copy_pkg
			sleep 20
	        else
			echo "Can't change to static content DIR"
			exit 1
		fi
else
	echo " PROBLEM IMPORTING USER PROFILE "
	exit 2
fi

exit 0
