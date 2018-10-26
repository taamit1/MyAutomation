#!/usr/bin/ksh

##### Function Starts Here
crt_link ()
{
	#### Creating Links to new EAR JAR
	echo "+++++++++++++++++++++++++++++++++"
	echo "+ Creating Links to new EAR JAR +"
	echo "+++++++++++++++++++++++++++++++++"
	source_ear=`awk -F"\"" '/SOURCE_EAR/ {print $2}' ${cwd}/S1envvars.sh`
	source_jar=`awk -F"\"" '/SOURCE_JAR/ {print $2}' ${cwd}/S1envvars.sh`
	Ear=`ls *${pkg_ver}*.ear`
	Jar=`ls *${pkg_ver}*.jar`

	echo "Old_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "Old_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`

	ln -fs ${Ear} ${source_ear}
	if [  $? -gt 0 ]
	then
		exit 1
	fi
	ln -fs ${Jar} ${source_jar}
	if [  $? -gt 0 ]
	then
		exit 1
	fi
	echo "New_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "New_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`
}

deploy_pkg ()
{
	S1deploy.sh
	if [ $? -eq 0 ]
	then
		echo " Application Deploy :  SUCCESS \n"
	else
		echo " Application Deploy :  FAILED \n"
		exit 2
	fi

}

install_pkg ()
{
      # check dmgr PID is active
      cd $WAS_HOME/../DeploymentManager/logs/dmgr/
      ps -fp `cat dmgr.pid` >>/dev/null 2>&1
      if test $? -ne 0
        then
          echo "Start the dmgr process and try again. \n"
          exit 1
        else
          echo "DMGR is up, so running S1install \n"
          . ${HOME}/.profile
          tostage
          S1install.sh
              if [ $? -eq 0 ]
        	then
              		echo " Application Install :  SUCCESS \n"
       		else
	              	echo " Application Install :  FAILED \n"
                        exit 3
              fi

        sleep 30
        echo "+++++++++++++++++++++++++++++++++"
        echo "+     Recycling cluster      +"
        echo "+++++++++++++++++++++++++++++++++"
        S1stopCluster.sh;sleep 30;S1startCluster.sh
      fi
}


##################Main Starts Here

pkg_ver=$1
fiid=$2

echo "$pkg_ver $fiid"
echo "Server Name:"`hostname`
. ${HOME}/.profile
#/bin/cd /platform/${fiid}/WebSphere/DeploymentManager/Stage/

tostage
if [ $? -eq 0 ]
then
	cwd=`pwd`

	echo " Current Directory on DMGR : ${cwd} \n"
	crt_link
	deploy_pkg
	install_pkg
else
	echo " PROBLEM IMPORTING USER PROFILE "

fi

exit 0
