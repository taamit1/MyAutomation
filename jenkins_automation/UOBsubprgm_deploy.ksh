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
	Ear=${uob_ear}
	Jar=${uob_jar}

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

	echo "Sleeping for 10 min after app install..."
        sleep 600

        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "+ Recycling ALL JVMs and Clearing WAS cache (temp,wstemp)     +"
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

 	/support/depot/scripts/killallv2.sh $finame
        if [ $? -eq 0 ]
        then
                echo "Killed all JVMs and deleted cached files : SUCCESS "
                echo "----------------------------------------------------------------------------------"
        else
                echo "Clear WAS cache and killing JVMs : FAILED "
                echo "------------------------------------------------------"
                exit 5
        fi
        sleep 5

	echo "Starting all the JVMs back............"
	echo
        arlm startManager;arlm startNode;arlm startCluster
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
  if [ -s $ARLM_STAGEROOT/Stage/extract.FILES2CHECK ]
  then
      echo "Check below files on app server `hostname` modified after installation...\n"
      cat $ARLM_STAGEROOT/Stage/extract.FILES2CHECK 2>&1
      echo "-------------------------------------------------------------------------"
  else
      echo "No files modified after install under batch or lib/ext...\n"
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

uob_ear=$1
uob_jar=$2
finame=$3

#echo "New EAR/JAR Version: ${uob_ear} ${uob_jar}"
echo "Server Name: "`hostname`
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
