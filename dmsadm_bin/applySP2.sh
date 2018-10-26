#####
# called from startIA2.sh or manually
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
  EP_VER_CUR="3.5.2.0H0"
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
 "10") EP_FP="10"
     ;;
 "11") EP_FP="11"
     ;;
 "A") # auto determine what FP to update
     case "$EP_VER_CUR" in
     3.5.2.1*) EP_FP="1"
      ;;
     3.5.2.2*) EP_FP="2"
      ;;
     3.5.2.3*) EP_FP="3"
      ;;
     3.5.2.4*) EP_FP="4"
      ;;
     3.5.2.5*) EP_FP="5"
      ;;
     3.5.2.6*) EP_FP="6"
      ;;
     3.5.2.7*) EP_FP="7"
      ;;
     3.5.2.8*) EP_FP="8"
      ;;
     3.5.2.9*) EP_FP="9"
      ;;
     3.5.2.10*) EP_FP="10"
      ;;
     3.5.2.11*) EP_FP="11"
      ;;
     *) EP_FP="0"       # new install take it to the latest
      ;;
     esac
     ;;
 "N") echo "N switch used, no fix packs applied"
      echo "Applied $EP_VER_CUR to `pwd` on `date`" |tee -a $EP_VER_FILE
      exit 0
     ;;
  *) echo "Usage applySP2.sh [FP#]"
     echo "  valid FP# = 1 - 11 (A = auto)"
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
    EP_VER="3.5.2.0H0"
    echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
    jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2.jar
   #rsync -cr ~dmsadm/source/Hosting/Banking/ ./
    find Actuate -print | cpio -pdum ../ 2>>/dev/null
    rm -rf Actuate
#
# for FP1
#
  elif test $EP_FP = "1"
  then
    case $EP_VER_CUR in
    "3.5.2.0H0") EP_VER="3.5.2.1H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.1H0"|"3.5.2.1H1"|"3.5.2.1H2") EP_VER="3.5.2.1H3"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1_HotFix1.jar
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1_HotFix2.jar
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1_HotFix3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.1H3") EP_VER="3.5.2.1H4"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1_HotFix4.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.1H4") EP_VER="3.5.2.1H5"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack1_HotFix5.jar
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
    "3.5.2.1H0") EP_VER="3.5.2.2H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack2.jar
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
    "3.5.2.2H0") EP_VER="3.5.2.3H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.3H0") EP_VER="3.5.2.3H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack3_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.3H1") EP_VER="3.5.2.3H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack3_HotFix2.jar
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
    "3.5.2.3H0") EP_VER="3.5.2.4H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack4.jar
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
    "3.5.2.4H0") EP_VER="3.5.2.5H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack5.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.5H0") EP_VER="3.5.2.5H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack5_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.5H1") EP_VER="3.5.2.5H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack5_HotFix2.jar
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
    "3.5.2.5H0") EP_VER="3.5.2.6H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack6.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.6H0") EP_VER="3.5.2.6H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack6_HotFix1.jar
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
    "3.5.2.6H0") EP_VER="3.5.2.7H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack7.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.7H0") EP_VER="3.5.2.7H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack7_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.7H1") EP_VER="3.5.2.7H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack7_HotFix2.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.7H2") EP_VER="3.5.2.7H3"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack7_HotFix3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.7H3") EP_VER="3.5.2.7H4"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack7_HotFix4.jar
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
    "3.5.2.7H0") EP_VER="3.5.2.8H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack8.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.8H0") EP_VER="3.5.2.8H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack8_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.8H1") EP_VER="3.5.2.8H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack8_HotFix2.jar
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
    "3.5.2.8H0") EP_VER="3.5.2.9H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.9H0") EP_VER="3.5.2.9H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.9H1") EP_VER="3.5.2.9H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix2.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.9H2") EP_VER="3.5.2.9H3"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.9H3") EP_VER="3.5.2.9H4"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix4.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.9H4") EP_VER="3.5.2.9H5"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix5.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;
    "3.5.2.9H5") EP_VER="3.5.2.9H6"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix6.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;

    "3.5.2.9H6") EP_VER="3.5.2.9H7"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix7.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;

    "3.5.2.9H7") EP_VER="3.5.2.9H8"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix8.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;


    "3.5.2.9H8") EP_VER="3.5.2.9H9"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix9.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;

    "3.5.2.9H9") EP_VER="3.5.2.9H10"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix10.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;

    "3.5.2.9H10") EP_VER="3.5.2.9H11"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack9_HotFix11.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;


    *) echo "Unknown version is $EP_VER_CUR for FP9. Check $EP_VER_FILE"

      exit 2
        ;;
    esac
#
# for FP10
#
  elif test $EP_FP = "10"
  then
    case $EP_VER_CUR in
    "3.5.2.9H0") EP_VER="3.5.2.10H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.10H0") EP_VER="3.5.2.10H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.10H1") EP_VER="3.5.2.10H2"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10_HotFix2.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.10H2") EP_VER="3.5.2.10H3"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10_HotFix3.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.10H3") EP_VER="3.5.2.10H4"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10_HotFix4.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.10H4") EP_VER="3.5.2.10H5"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack10_HotFix5.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
      ;;

    *) echo "Unknown version is $EP_VER_CUR for FP10. Check $EP_VER_FILE"

      exit 2
        ;;
    esac
#
# for FP11
#
  elif test $EP_FP = "11"
  then
    case $EP_VER_CUR in
    "3.5.2.10H0") EP_VER="3.5.2.11H0"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack11.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    "3.5.2.11H0") EP_VER="3.5.2.11H1"
      echo "Current version is $EP_VER_CUR.  Applying $EP_VER ..."
      jar xf ~dmsadm/source/S1_Enterprise_Banking_Solutions3.5_ServicePack2_FixPack11_HotFix1.jar
#      rsync -cr ~dmsadm/source/Hosting/Banking/ ./
      find Actuate -print | cpio -pdum ../ 2>>/dev/null
      rm -rf Actuate
        ;;
    *) echo "Unknown version is $EP_VER_CUR for FP11. Check $EP_VER_FILE"

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
