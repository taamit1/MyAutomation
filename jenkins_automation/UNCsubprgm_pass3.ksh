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
	source_ear=`awk -F"\"" '/SOURCE_EAR/ {print $2}' ${cwd}/S1envvars.sh`
	source_jar=`awk -F"\"" '/SOURCE_JAR/ {print $2}' ${cwd}/S1envvars.sh`
	Ear=`ls *${pkg_ver}*.ear`
	Jar=`ls *${pkg_ver}*.jar`

	echo "Old_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "Old_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`
	echo
	ln -fs ${Ear} ${source_ear}
	if [  $? -gt 0 ]
	then
		exit 2
	fi
	ln -fs ${Jar} ${source_jar}
	if [  $? -gt 0 ]
	then
		exit 2
	fi
	echo "New_EAR : "`ls -l ${source_ear} | awk -F"-> " '{print $2}'`
	echo "New_JAR : "`ls -l ${source_jar} | awk -F"-> " '{print $2}'`
	echo
}

deploy_pkg ()
{
	S1deploy.sh
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
        S1install.sh
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

        echo "Sleeping for 8 min after app install...\n"
	sleep 480

        echo "+++++++++++++++++++++++++++++++++"
        echo "+     Recycling cluster      +"
        echo "+++++++++++++++++++++++++++++++++"
        S1stopCluster.sh
        if [ $? -eq 0 ]
        then
            echo "Cluster stop :  SUCCESS "
	    echo "------------------------------------------------------"
        else
            echo "Cluster stop :  FAILED "
	    echo "------------------------------------------------------"
            exit 5
        fi
	sleep 30

	S1startCluster.sh
        if [ $? -eq 0 ]
        then
            echo "Cluster start :  SUCCESS "
	    echo "------------------------------------------------------"
        else
            echo "Cluster start :  FAILED "
	    echo "------------------------------------------------------"
            exit 6
        fi

	echo "Recycling the cluster again...\n"
        sleep 300
	S1stopCluster.sh;sleep 20;S1startCluster.sh
}

check_extractfiles()
{
  # check S1extract.FILES2CHECK file
  if [ -f ${cwd}/S1extract.FILES2CHECK ]
  then
      echo "Check below files on app server `hostname` modified after install...\n"
      cat ${cwd}/S1extract.FILES2CHECK 2>&1
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

echo "New Version: $pkg_ver $fiid"
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
else
	echo "PROBLEM IMPORTING USER PROFILE, check on app server... "
	exit 7
fi

exit 0
