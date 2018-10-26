#
# start eclipse for a given user environment
#
ADMUSER="dmsadm"
DISPLAY_ALL="97 98 99"

LOCK_DIR="/platform/${ADMUSER}/${ADMUSER}.lck/"
LOGFILE="/platform/${ADMUSER}/${ADMUSER}.log"
AUTHFILE="/platform/${ADMUSER}/${ADMUSER}.auth"
HOSTNAME=`hostname`
export JAVA_HOME=/usr/java6
export E_JVM=$JAVA_HOME/jre/bin/java
export PATH=$PATH:$JAVA_HOME/bin
export E_HOME=/opt/eclipse302

if [ -f /platform/${ADMUSER}/sqllib/db2profile ]; then
    . /platform/${ADMUSER}/sqllib/db2profile
fi

APPLY_FLAG="$1"
[ -z "$APPLY_FLAG" ] && APPLY_FLAG="A"
export APPLY_FLAG

#unset CLASSPATH
#CLASSPATH=.
#for x in \
#   ~${ADMUSER}/apache-ant-1.7.0/lib/*.jar
#do
#  CLASSPATH=$CLASSPATH:$x
#done
#export CLASSPATH

FINAME=`echo $LOGNAME|sed -e "s/^dms/fi/" -e "s/^dm/fi/"`
LOGINUSER=`who am i |cut -f1 -d' '`
SCRNAME=$0

if test -s ${LOCK_DIR}user.$FINAME
then
  LOCK_DISP=`tail -1 ${LOCK_DIR}user.$FINAME`
  echo "A X-window session ":$LOCK_DISP" is already active for $FINAME"
  exit 1
fi

if test ! -d /platform/$FINAME
then
  echo "The product directory /platform/$FINAME can not be found"
  exit 1
fi
export E_WORK=/platform/$FINAME/workspace

# manual display
if test "$SCRNAME" = "startTools.sh" -a "$1" != ""
then
  DISPLAY_ALL="$1"
fi

# set display
unset DISPLAY
for DISPLAY_CHK in $DISPLAY_ALL
do
  if test ! -s ${LOCK_DIR}disp.${DISPLAY_CHK}
  then
    export DISPLAY=${HOSTNAME}:$DISPLAY_CHK
    break
  fi
done

if test "$DISPLAY" = ""
then
  echo "All DISPLAYs are in use. Locked DISPLAYs are: $DISPLAY_ALL"
  exit 1
fi

date > ${LOCK_DIR}disp.$DISPLAY_CHK
echo $LOGINUSER >> ${LOCK_DIR}disp.$DISPLAY_CHK
echo $DISPLAY_CHK >> ${LOCK_DIR}disp.$DISPLAY_CHK
date > ${LOCK_DIR}user.$FINAME
echo $LOGINUSER >> ${LOCK_DIR}user.$FINAME
echo $DISPLAY_CHK >> ${LOCK_DIR}user.$FINAME

# merge xauth data
cat ~${ADMUSER}/${ADMUSER}.xauth.$DISPLAY |xauth merge \- >>/dev/null 2>&1

export LOCK_DIR DISPLAY_CHK DISPLAY FINAME
case "$SCRNAME" in
 "startEclipse.sh")
   echo "$LOGINUSER is running eclipse as $LOGNAME for $FINAME on <$DISPLAY> @ `date`"|tee -a $LOGFILE
   echo
   aixterm -geometry +0+0 -title "$LOGINUSER running Eclipse as $LOGNAME for $FINAME"&
   export CPID=$!
   (cd $HOME; \
    $E_HOME/eclipse -data $E_WORK -vm $E_JVM -vmargs -Xmx512m; \
    kill -9 $CPID;rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME)&
   echo "Started process PID $!"
  ;;
  "startIA.sh")
   echo "$LOGINUSER is running IA as $LOGNAME for $FINAME on <$DISPLAY> @ `date`"|tee -a $LOGFILE
   echo
   if test -s ~${ADMUSER}/source/S1_Enterprise_Banking_Solutions3.5_ServicePack1.zip
   then
     cd /platform/$FINAME
     unzip -oq ~${ADMUSER}/source/S1_Enterprise_Banking_Solutions3.5_ServicePack1.zip
     if test $? -eq 0
     then
       echo "Installer unzipped..."
       aixterm -geometry +0+0 -title "$LOGINUSER running IA as $LOGNAME for $FINAME"&
       export CPID=$!
       (chmod u+x /platform/$FINAME/Disk1/InstData/NoVM/install.bin; \
         /platform/$FINAME/Disk1/InstData/NoVM/install.bin; \
         ~${ADMUSER}/bin/applyFP.sh $APPLY_FLAG; \
         kill -9 $CPID;rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME; rm -rf /platform/$FINAME/Disk1)&
       echo "Started process PID $!"
     else
       echo "Installer failed to unzip."
       rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME
     fi
   else
     echo "Installer not found!"
     rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME
   fi
  ;;
  "startIA2.sh")
   echo "$LOGINUSER is running IA2 as $LOGNAME for $FINAME on <$DISPLAY> @ `date`"|tee -a $LOGFILE
   echo
   if test -s ~${ADMUSER}/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2.zip
   then
     cd /platform/$FINAME
     unzip -oq ~${ADMUSER}/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2.zip
     if test $? -eq 0
     then
       echo "Installer unzipped..."
       aixterm -geometry +0+0 -title "$LOGINUSER running IA2 as $LOGNAME for $FINAME"&
       export CPID=$!
       (chmod u+x /platform/$FINAME/Disk1/InstData/NoVM/install.bin; \
         /platform/$FINAME/Disk1/InstData/NoVM/install.bin; \
         ~${ADMUSER}/bin/applyFP2.sh N; \
         kill -9 $CPID;rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME; rm -rf /platform/$FINAME/Disk1 /platform/$FINAME/META-INF)&
       echo "Started process PID $!"
     else
       echo "Installer failed to unzip."
       rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME
     fi
   else
     echo "Installer not found!"
     rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME
   fi
  ;;
 "startTest.sh")
   echo "$LOGINUSER is running Test as $LOGNAME for $FINAME on <$DISPLAY> @ `date`"|tee -a $LOGFILE
   echo
   aixterm -geometry +0+0 -title "$LOGINUSER running Test as $LOGNAME for $FINAME"&
   export CPID=$!
   echo "debug CPID=$CPID"
     (xclock; \
     kill -9 $CPID;rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME)&
   echo "Started process PID $!"
  ;;
 "startTools.sh")
   echo "$LOGINUSER is running TOOLS as $LOGNAME for $FINAME on <$DISPLAY> @ `date`"|tee -a $LOGFILE
   echo
   aixterm -geometry +0+0 -title "$LOGINUSER running TOOLS $LOGNAME for $FINAME"&
   export CPID=$!
     (launchTools.sh; \
     kill -9 $CPID;rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME)&
   echo "Started process PID $!"
  ;;
  *)
    echo "Unknown script name: $SCRNAME"
    rm -f ${LOCK_DIR}disp.$DISPLAY_CHK ${LOCK_DIR}user.$FINAME
  ;;
esac

exit 0

