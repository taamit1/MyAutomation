#####
# apply37.sh
#####
FINAME=`echo $LOGNAME|sed -e "s/dms/fi/"`

EP_VER_FILE="/platform/$FINAME/.ep_ver"

INST_WORKLOC="/platform/$FINAME/tmp/EP"
INST_LOCATION="/platform/$FINAME/s1env/EP"
if test ! -d $INST_LOCATION
then
  INST_LOCATION="/platform/$FINAME/EP"
fi
if test ! -d $INST_LOCATION
then
  echo "Install location(s) can not be found"
  exit 1
fi

#
# get current version
#
if test -s $EP_VER_FILE
then
  EP_VER_CUR=`awk '{print $2}' $EP_VER_FILE |tail -1`
else
  EP_VER_CUR="3.7.0.0H0"
fi

#
#
#
case "$1" in
 "0") EP_FP="0"
     ;;
 "1") EP_FP="1"
     ;;
 "2") EP_FP="2"
     ;;
 "3") EP_FP="3"
     ;;
 "4") EP_FP="4"
     ;;
 "5") EP_FP="5"
     ;;
 "6") EP_FP="6"
     ;;
 "7") EP_FP="7"
     ;;
 "8") EP_FP="8"
     ;;
 "9") EP_FP="9"
     ;;
 "A") # auto determine what FP to update
     case "$EP_VER_CUR" in
     3.7.0.1*) EP_FP="1"
      ;;
     *) EP_FP="9"       # new install take it to the latest
      ;;
     esac
     ;;
 "N") echo "N switch used, no fix packs applied"
      echo "Applied $EP_VER_CUR to `pwd` on `date`" |tee -a $EP_VER_FILE
      exit 0
     ;;
  *) echo "Usage apply37.sh [FP#]"
     echo "  valid FP# = 1 - 9  (A = auto)"
     exit 1
     ;;
esac

rm -rf $INST_WORKLOC
if test ! -d $INST_WORKLOC
then
  mkdir -p $INST_WORKLOC
  if test $? -ne 0
  then
    echo "ERROR: could not create directory $INST_WORKLOC"
    exit 1
  fi
fi

#
# Build the updates
#
cd $INST_WORKLOC
if test $? -ne 0
then
  echo "ERROR: could not cd to directory $INST_WORKLOC"
  echo "Did not extract updates, could not find $INST_LOCATION"
  exit 2
else
  mkdir Banking Actuate
  cd Banking
#
# for FP0
#
  if test $EP_FP = "0"
  then
    EP_VER="3.7.0.0H0"
    echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
   # jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2.jar
   #rsync -cr ~dmsadm/source/Hosting/Banking/ ./
   # find Actuate -print | cpio -pdum ../ 2>>/dev/null
   # rm -rf Actuate
#
# for FP1
#
  elif test $EP_FP = "1"
  then
    case $EP_VER_CUR in
    "3.7.0.0H0") EP_VER="3.7.0.1H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP1. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP2
#
  elif test $EP_FP = "2"
  then
    case $EP_VER_CUR in
    "3.7.0.1H0") EP_VER="3.7.0.2H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack2.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP2. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP3
#
  elif test $EP_FP = "3"
  then
    case $EP_VER_CUR in
    "3.7.0.2H0") EP_VER="3.7.0.3H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP3. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP4
#
  elif test $EP_FP = "4"
  then
    case $EP_VER_CUR in
    "3.7.0.3H0") EP_VER="3.7.0.4H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack4.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP4. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP5
#
  elif test $EP_FP = "5"
  then
    case $EP_VER_CUR in
    "3.7.0.4H0") EP_VER="3.7.0.5H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack5.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP5. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP6
#
  elif test $EP_FP = "6"
  then
    case $EP_VER_CUR in
    "3.7.0.5H0") EP_VER="3.7.0.6H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack6.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP6. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP7
#
  elif test $EP_FP = "7"
  then
    case $EP_VER_CUR in
    "3.7.0.6H0") EP_VER="3.7.0.7H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack7.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP7. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP8
#
  elif test $EP_FP = "8"
  then
    case $EP_VER_CUR in
    "3.7.0.7H0") EP_VER="3.7.0.8H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack8.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP8. Check $EP_VER_FILE"
      exit 2
        ;;
    esac
#
# for FP9
#
  elif test $EP_FP = "9"
  then
    case $EP_VER_CUR in
    "3.7.0.8H0") EP_VER="3.7.0.9H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.7_Release0_FixPack9.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP9. Check $EP_VER_FILE"
      exit 2
        ;;
    esac

  fi

fi

INST_BACKUPNAM="$INST_LOCATION/../backup.$EP_VER.cpio"

#
# Copy in the updates, leave backup file ending in ~
#
if test -d $INST_LOCATION
then
  cd $INST_LOCATION

  # backup existing ~ files first
  find . -name "*~" -print | cpio -oc >$INST_BACKUPNAM 2>>/dev/null
  if test $? -ne 0
  then
    echo "ERROR: could not backup old *~ files"
  fi
  gzip $INST_BACKUPNAM
  find . -name "*~" -exec rm -f {} \;

  # apply updates
  echo "Applying $EP_VER to `pwd` on `date`" |tee -a $EP_VER_FILE
  rsync -cbr $INST_WORKLOC/ ./
else
  echo "Did not copy updates, could not find $INST_LOCATION"
fi

rm -rf $INST_WORKLOC
exit 0
