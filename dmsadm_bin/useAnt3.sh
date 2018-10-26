#!/bin/ksh

S1ANTHOME1="$HOME/s1env/EP/build/S1-INSTALL-INF"
S1ANTHOME2="$HOME/s1env/EP"
S1BLDHOME="$HOME/s1env/EP/build"
S1CUSTHOME="$HOME/s1env/EP/custom"


FINAME=`echo $LOGNAME|sed -e "s/dms/fi/"`

if [ -f /platform/dmsadm/sqllib/db2profile ]; then
    . /platform/dmsadm/sqllib/db2profile
fi

export PATH=$PATH:/support/bin/apache-ant-1.7.0/bin:/usr/local/bin

export ENVMGRLIB=/support/bin/envMgrCli/lib
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/castor-0.9.6-xml.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/cli_envmanager.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/jakarta-oro-2.0.7.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/model.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/s1antsupport.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/s1tasks.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/xalan.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/commons-logging.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/commons-io-1.0.jar
export CLASSPATH=$CLASSPATH:$ENVMGRLIB/dbinstaller.jar

#
# SVN tasks
#
REPO_ROOT="/dms"
umask 002

groups | grep "svngrp" >>/dev/null 2>&1
if test $? -ne 0
then
  echo "Error: This user must belong to the svngrp group before continuing."
  echo "       Contact an AIX administrator to have this user added to svngrp group"
  exit 2
fi

#
# should version be changed
#
BUILD_TASK="$1"
case "$BUILD_TASK" in
  *-jar|*-all|*-deploy) CHANGE_VER="Y"
  ;;
  test) CHANGE_VER="N"
  ;;
  *) CHANGE_VER="N"
  ;;
esac

#
# setup for svn checkin and get message
#
cd $S1CUSTHOME
if test $? -ne 0
then
  echo "ERROR: failed to cd to $S1CUSTHOME"
  exit 1
fi

# check for repo
if test ! -s $REPO_ROOT/$FINAME/format
then
  echo "Error: SVN repository $REPO_ROOT/$FINAME does not exist."
  echo "       Run makeEnv.sh to create initial repository for FI"
  echo "       Continuing without svn support."
  SVN_AVAIL="N"
else
  SVN_AVAIL="Y"
  svn status >/tmp/ua$$
  if test $? -ne 0
  then
    echo "Warning: svn status command failed.  Continuing without svn support."
    SVN_AVAIL="N"
  else
    NUM_MOD=`grep -e "^M" /tmp/ua$$ |wc -l|sed -e "s/ //g"`
    NUM_ADD=`grep -e "^\?" /tmp/ua$$ |wc -l|sed -e "s/ //g"`
    NUM_DEL=`grep -e "^\!" /tmp/ua$$ |wc -l|sed -e "s/ //g"`
    cat /tmp/ua$$
    rm -f /tmp/ua$$
    SVN_MSG1="$NUM_MOD modified, $NUM_ADD new, $NUM_DEL deleted files"
    echo "SVN has found: $SVN_MSG1"
    echo
    echo "Commit changes and continue with build? \c"
    read ans
    if test "$ans" = "y" -o "$ans" = "Y"
    then
      echo "Committing changes..."
      svn status |awk '/^\?/ {print $2}'|xargs svn add
      if test $? -ne 0
      then
        echo "ERROR: svn add failed.  Check messages."
        exit 1
      fi
      svn status |awk '/^\!/ {print $2}'|xargs svn rm
      if test $? -ne 0
      then
        echo "ERROR: svn delete failed.  Check messages."
        exit 1
      fi
      svn ci -m "$SVN_MSG1"
      if test $? -ne 0
      then
        echo "ERROR: svn failed to commit changes.  Check messages."
        exit 1
      fi
    else
      echo "Exiting...you can run svn status from custom to view changes"
      exit 0
    fi
  fi
fi


#
# setup version and build.xml
#
cd $S1ANTHOME1
if test $? -ne 0
then
  cd $S1ANTHOME2
  if test $? -ne 0
  then
    echo "ERROR: failed to cd to $S1ANTHOME2"
    exit 1
  fi
fi

#
# get/change current version
#
EP_VER_FILE="$HOME/.ep_ver"
if test -s $EP_VER_FILE
then
  EP_VER_CUR=`awk '{print $2}' $EP_VER_FILE |tail -1`
  if test "$CHANGE_VER" = "Y"
  then
    EP_VER_FI=`echo $EP_VER_CUR |awk '{if (index($1,"V") == 0) {s=$1;v=0} else{s=substr($1,0,index($1,"V") - 1);v=substr($1,index($1,"V") + 1)} v=v+1;print s "V" v}'`
  else
    EP_VER_FI=`echo $EP_VER_CUR |awk '{if (index($1,"V") == 0) {s=$1;v=0} else{s=substr($1,0,index($1,"V") - 1);v=substr($1,index($1,"V") + 1)} v=v+0;print s "V" v}'`
  fi
  echo "$FINAME $EP_VER_FI" >build.ver
  EP_VER_CUR=`echo $EP_VER_CUR|sed 's/V.*$//'`
else
  EP_VER_CUR="3.5.1.0H0"
  EP_VER_FI="${EP_VER_CUR}V0"
  echo "$FINAME $EP_VER_FI" >build.ver
fi

#
# generate a build-tiles.xml file
#
TILESFILE="build-tiles.xml"
echo '<?xml version="1.0" encoding="UTF-8"?>' >$TILESFILE
echo >>$TILESFILE
echo '<tiles-definitions>' >>$TILESFILE
echo '  <definition name="coreDefinition" dir="bnkweb-bb/WebContent/WEB-INF/config/common/ext" file="base-tiles-definitions.xml">' >>$TILESFILE
echo '    <put name="navCopyrightTitle" value="Opens copyright info page in new window - ('$EP_VER_FI')"></put>' >>$TILESFILE
echo '  </definition>' >>$TILESFILE
echo '  <definition name="coreDefinition" dir="bnkweb-pb/WebContent/WEB-INF/config/common/ext" file="base-tiles-definitions.xml">' >>$TILESFILE
echo '    <put name="navCopyrightTitle" value="Opens copyright info page in new window - ('$EP_VER_FI')"></put>' >>$TILESFILE
echo '  </definition>' >>$TILESFILE
echo '  <definition name="appNavDefinition" dir="bnkweb-sam/WebContent/WEB-INF/config/app/ext" file="app-nav-tiles-definitions.xml">' >>$TILESFILE
echo '    <put name="navCopyrightTitle" value="Opens copyright info page in new window - ('$EP_VER_FI')"></put>' >>$TILESFILE
echo '  </definition>' >>$TILESFILE
echo '  <definition name="coreDefinition" dir="bnkweb-sam/WebContent/WEB-INF/config/common/ext" file="base-tiles-definitions.xml">' >>$TILESFILE
echo '    <put name="navCopyrightTitle" value="Opens copyright info page in new window - ('$EP_VER_FI')"></put>' >>$TILESFILE
echo '  </definition>' >>$TILESFILE
echo '</tiles-definitions>' >>$TILESFILE

#
# set BLD_VER
#
if test -d ~dmsadm/source/Build/$EP_VER_CUR
then
  BLD_VER="$EP_VER_CUR"
else
  BLD_VER="default"
fi

#
# copy template files
#
echo "Copying templates from `ls -d ~dmsadm/source/Build/$BLD_VER` ..."
for TNAM in `ls ~dmsadm/source/Build/$BLD_VER/build.properties ~dmsadm/source/Build/$BLD_VER/*.xml`
do
  BNAM=`basename $TNAM`
#  if test ! -s $BNAM
#  if test $TNAM -nt $BNAM
#  then
#    echo "copy $BNAM template..."
    cat $TNAM | sed -e "s/FINAME/$FINAME/g" >$BNAM
#  fi
done

#
# create build-dms.properties
#
echo "# DMS properties" >build-dms.properties
echo "build.dms.finame=$FINAME" >>build-dms.properties
EP_VER_SHORT=`echo $EP_VER_FI |sed -e "s/EP//" -e "s/\.//g"`
echo "build.dms.version=$EP_VER_SHORT" >>build-dms.properties

#
# update version file with build version
#
S1ANTLOG="$S1BLDHOME/Build_SSB_${EP_VER_SHORT}_${FINAME}.log"
echo "Build $EP_VER_FI for $HOME/s1env/EP on `date`" |tee -a $EP_VER_FILE|tee -a $S1ANTLOG

#
# create svn builds tag & update working copy
#
CWD=`pwd`
if test "$SVN_AVAIL" = "Y" -a "$CHANGE_VER" = "Y"
then
  cd $S1CUSTHOME
  echo
  echo "Marking SVN builds version $EP_VER_FI..."|tee -a $S1ANTLOG
  svn copy file://$REPO_ROOT/$FINAME/branches/$EP_VER_CUR file://$REPO_ROOT/$FINAME/builds/$EP_VER_FI -m"$EP_VER_FI"|tee -a $S1ANTLOG
  svn update|tee -a $S1ANTLOG
  echo|tee -a $S1ANTLOG
fi
cd $CWD

#
# run ant
#
echo "Working directory is `pwd`" |tee -a $S1ANTLOG
date |tee -a $S1ANTLOG
ant $BUILD_TASK 2>&1 |tee -a $S1ANTLOG

#
# clean up
#

# remove s1ear /tmp work files
echo "\nCleaning up s1ear /tmp files:"
for NAM in `find /tmp -name "S1*ear" -user $LOGNAME 2>>/dev/null`
do
  echo "Removing $NAM ..."
  rm -rf $NAM
done

# keep just last 3 ear/jar files
PURGE_VERS=3
cd $S1BLDHOME
if test $? -eq 0
then
  echo "\nCleaning up old ear/jar files in `pwd`:"
  CNT=0
  for NAM in `ls -t Build_SSB_*_${FINAME}.log`
  do
    CNT=$(($CNT + 1))
    if test $CNT -gt $PURGE_VERS
    then
      echo "Removing all $NAM related files ..."
      rm -f $NAM
      ONAM=`echo $NAM |sed -e "s/^Build/DB/" -e "s/log$/jar/"`
      rm -f $ONAM
      ONAM=`echo $NAM |sed -e "s/^Build/Config/" -e "s/log$/jar/"`
      rm -f $ONAM
      ONAM=`echo $NAM |sed -e "s/^Build/EP/" -e "s/log$/ear/"`
      rm -f $ONAM
    fi
  done
fi

#
# EOS
#
