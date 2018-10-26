#!/usr/bin/ksh

##### Function Starts Here
check_dmgr ()
{
      # check if dmgr PID is active or not
      cd $WAS_HOME/../DeploymentManager/logs/dmgr/
      ps -fp `cat dmgr.pid` >>/dev/null 2>&1
      if test $? -ne 0
      then
	  echo "##############################################################################"
          echo "ERROR: Start the dmgr process on app server and try running deploy job again.."
	  echo "##############################################################################"
          exit 1
      else
          echo
      fi
}

crt_link ()
{
	echo "+++++++++++++++++++++++++++++++++"
	echo "+ Creating Links to new EAR JAR +"
	echo "+++++++++++++++++++++++++++++++++"
	source_ear=`awk -F"\"" '/SOURCE_EAR/ {print $2}' ${cwd}/envvars.sh`
	source_jar=`awk -F"\"" '/SOURCE_JAR/ {print $2}' ${cwd}/envvars.sh`
	Ear=`ls *${pkg_ver}*.ear`
	Jar=`ls *${pkg_ver}*.jar`

	echo "Old_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "Old_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`

	ln -fs ${Ear} ${source_ear}
	if [ $? -gt 0 ]
	then
	  exit 2
	fi
	ln -fs ${Jar} ${source_jar}
	if [ $? -gt 0 ]
	then
	  exit 2
	fi
	echo
	echo "New_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "New_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`
	echo
}

deploy_pkg ()
{
	arlm deploy
	if [ $? -eq 0 ]
	then
		echo "------------------------------------------------------"
		echo "Application Deploy :  SUCCESS "
		echo "------------------------------------------------------"
	else
		echo "------------------------------------------------------"
		echo "Application Deploy :  FAILED "
		echo "------------------------------------------------------"
		exit 3
	fi
}

install_pkg ()
{
	arlm APPinstall
        if [ $? -eq 0 ]
        then
        	echo "------------------------------------------------------"
		echo "Application Install :  SUCCESS "
		echo "------------------------------------------------------"
       	else
		echo "------------------------------------------------------"
	        echo "Application Install :  FAILED "
		echo "------------------------------------------------------"
                exit 4
        fi

	echo "Sleeping for 5 min after app install..."
        sleep 300

        echo "+++++++++++++++++++++++++++++++++"
        echo "+     Recycling cluster      +"
        echo "+++++++++++++++++++++++++++++++++"
        arlm stopCluster
	if [ $? -eq 0 ]
        then
                echo "Cluster stop :  SUCCESS "
		echo "------------------------------------------------------"
        else
                echo "Cluster stop :  FAILED "
		echo "------------------------------------------------------"
                exit 5
        fi
	sleep 20

	arlm startCluster
        if [ $? -eq 0 ]
        then
                echo "Cluster start :  SUCCESS "
		echo "------------------------------------------------------"
        else
                echo "Cluster start :  FAILED "
		echo "------------------------------------------------------"
                exit 6
        fi
}

check_extractfiles()
{
  # check extract.FILES2CHECK file
  if [ -f $ARLM_STAGEROOT/Stage/extract.FILES2CHECK ]
  then
      echo "Check below files on app server `hostname` modified after installation...\n"
      cat $ARLM_STAGEROOT/Stage/extract.FILES2CHECK 2>&1
      echo "-------------------------------------------------------------------------"
  fi
}

cleanup_old()
{
    # keep just last 3 ear/jar files
    echo "Cleaning up old ear/jars in `pwd`:"
    ls -t|grep -E EP.*ear|awk 'NR>4'|xargs rm -f
    ls -t|grep -E Config.*jar|awk 'NR>4'|xargs rm -f
}

## Main Starts Here

pkg_ver=$1
fiid=$2

echo "New Version:$pkg_ver $fiid"
echo "Server Name:"`hostname`
. ${HOME}/.profile >/dev/null 2>&1

#Check dmgr process is active or not
check_dmgr

tostage
if [ $? -eq 0 ]
then
	cwd=`pwd`
	echo "Current Directory on DMGR : ${cwd} \n"
	crt_link
	echo "------------------------------------------------------"
	deploy_pkg
        sleep 20
	install_pkg
	check_extractfiles
	cleanup_old
        sleep 30
else
	echo "PROBLEM IMPORTING USER PROFILE "
	exit 7
fi

exit 0
