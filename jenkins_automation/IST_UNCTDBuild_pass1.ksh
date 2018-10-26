#!/usr/bin/ksh
if [ $# -ne 2 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID> <DMSUSER>"
	echo " Example: $0 fi9999 dms9999"
        exit 1
fi

cwd="/packages/automation"
fiid=$1
dmsusr=$2
idfi=`echo ${fiid#??}`
dt=`date +"%d%b%Y%H%M%S"`
dt1=`date +"%d-%b-%Y"`

srcpath="/istplatform/${fiid}"
pkgpath="/packages/${fiid}"
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_pass1.log"

PRODNAME="Banking"
if test ! -d ${srcpath}/s1env/EP/$PRODNAME
then
  PRODNAME="CorporateBanking"          # if not Banking try to use CorporateBanking
  if test ! -d ${srcpath}/s1env/EP/$PRODNAME
  then
    PRODNAME="CBInternational"          # if not Banking try to use CorporateBanking
    if test ! -d ${srcpath}/s1env/EP/$PRODNAME
    then
      PRODNAME="TradeFinance"          # if not CorporateBanking try to use TradeFinance
      if test ! -d ${srcpath}/s1env/EP/$PRODNAME
      then
        PRODNAME="NAO"          # if not TradeFinance try to use NAO
        if test ! -d ${srcpath}/EP/$PRODNAME
        then
          PRODNAME="UOB"
          echo "You're building for UOB/EB."
          echo ""
          echo "So please use UOB build scripts for UOB/EB builds."
          echo ""
          exit 1
       fi
      fi
    fi
  fi
fi

svnpath="${srcpath}/s1env/EP/${PRODNAME}"
EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'T' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

# check if core patch folder is writable for dmsusr
if ls -ld ${patchpath}|grep -q ^drwxrwxr-x >/dev/null 2>&1
then
  continue
else
  chmod 775 ${patchpath} >/dev/null 2>&1
fi

## Checking if build is triggered by mistake
if [ ! -f ${pkgpath}/*.zip ]
then
        echo "*****************************************************************************"
        echo "WARNING: There are no custom jar/zip package found under /packages/${fiid}   "
        echo "on DMS (epdms01), So CONTINUING without the custom package for ${fiid}       "
        echo "*****************************************************************************"
        #exit 0
fi

mkdir ${logpath}
echo ${dt} > ${pkgpath}/istblddtl

## This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/dtout >&3 &
pid_out=$!
exec  1>${logpath}/dtout
exec  2>${logpath}/dtout

echo "-------------------------------------------------------------"
date;echo

chown -R ${dmsusr}.staff ${logpath} >/dev/null 2>&1
chown ${dmsusr}.staff *.* >/dev/null 2>&1

PKGCNT=`ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|wc -l`
if [ ${PKGCNT} -gt 6 ]
then
  echo "Removing old DIRs from Package Upload DIR..."
  ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|xargs rm -rf 2>/dev/null
fi

echo "------------------------------------------------------"
sudo su - $dmsusr -c "${cwd}/IST_UNCTDsubprgm_pass1.ksh ${fiid} ${dt}" 2>/dev/null

exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/dtout

### Logging New Package to details
### Get latest version info
pkg_ver=`awk -F"EP|CI|CB|TO|NA|UB|OB" '/Build/ {gsub(/\./,"");print $2}' ${logfile}| head -1| awk -F"for" '{print $1}'`
grep $pkg_ver ${logfile}|awk -F":" '{print $2}' | sort | uniq > ${logpath}/pkg_info

if grep "CB" $pkg_info >/dev/null 2>&1
then
  patch_rpt="${srcpath}/s1env/EP/build/Patch_CB${pkg_ver}_${fiid}.rpt"
elif grep "CI" $pkg_info >/dev/null 2>&1
then
  patch_rpt="${srcpath}/s1env/EP/build/Patch_CI${pkg_ver}_${fiid}.rpt"
else
  patch_rpt="${srcpath}/s1env/EP/build/Patch_${pkg_ver}_${fiid}.rpt"
fi

egrep "BUILD FAILED|ERROR:|\*ERROR\*" ${logfile} >/dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "BUILD FAILED, please check the above build logs..."
  echo "-------------------------------------------------------------------"
  date
  echo "-------------------------------------------------------------------"
  exit 1
else
  echo "Check above build logs and below build artifacts and then run required deploy jobs...\n"
  if [ -f ${patch_rpt} ]
  then
        totalpatch=`egrep "SSB-..... -|COR-..... -|GBS-..... -" $patch_rpt|wc -l` 2>&1
        echo "-------------------------------------------------------------------"
        echo "Total Applied Core Patches in this build are :$totalpatch \n"
        egrep "SSB-..... -|COR-..... -|GBS-..... -" $patch_rpt 2>&1
        echo "-------------------------------------------------------------------"
  fi

  echo "New Build artifacts are shown below..."
  cat ${logpath}/pkg_info 2>&1
  echo "-------------------------------------------------------------------"
  date
  echo "-------------------------------------------------------------------"
  exit 0
fi
