#!/bin/ksh

S1ANTHOME1="$HOME/s1env/EP/build/S1-INSTALL-INF"
S1ANTHOME2="$HOME/s1env/EP"
S1BLDHOME="$HOME/s1env/EP/build"


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
# get current version
#
EP_VER_FILE="$HOME/.ep_ver"
if test -s $EP_VER_FILE
then
  EP_VER_CUR=`awk '{print $2}' $EP_VER_FILE |tail -1`
  EP_VER_FI=`echo $EP_VER_CUR |awk '{if (index($1,"V") == 0) {s=$1;v=0} else{s=substr($1,0,index($1,"V") - 1);v=substr($1,index($1,"V") + 1)} v=v+1;print s "V" v}'`
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
echo "Build $EP_VER_FI for $HOME/s1env/EP on `date`" |tee -a $EP_VER_FILE

#
# run ant
#
S1ANTLOG="$S1BLDHOME/Build_SSB_${EP_VER_SHORT}_${FINAME}.log"
echo "Working directory is `pwd`" |tee -a $S1ANTLOG
date |tee -a $S1ANTLOG
ant $* 2>&1 |tee -a $S1ANTLOG

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
