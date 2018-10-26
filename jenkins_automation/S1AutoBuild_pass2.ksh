#!/usr/bin/ksh

if [ $# -ne 2 ]
then
        # if  bankenv not passed, send error and exit
        echo " Usage: $0 <FIID>  <DMSUSER>"
	echo " Example: $0 fi9999 dms9999"
        exit 1
fi

cwd="/packages/automation"
fiid=$1
dmsusr=$2

srcpath="/platform/${fiid}"
pkgpath="/packages/${fiid}"
dt=`cat ${pkgpath}/blddtl`
logpath="${pkgpath}/${dt}"
logfile="${logpath}/build_pass2.log"

echo "------------------------------------------------------"
date

## Checking if script is run by mistake
if [ ! -f ${pkgpath}/blddtl ]
then
	echo "There is no build detail available for now ..."
	echo "You seem to have run the script by mistake ..."
	echo "Execute Pass1 before running Pass2 ..."
	echo "Exiting ......................................"
	exit 1
fi

##### This is for logging intelegance
dtout=dt`date +"%d%b%Y%H%M%S"`
mkfifo ${logpath}/$dtout
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/$dtout >&3 &
pid_out=$!
exec  1>${logpath}/$dtout
exec  2>${logpath}/$dtout

## Running the subprogram for actual build
sudo su - $dmsusr -c "${cwd}/subprgm_pass2.ksh ${fiid} ${dt}" 2>/dev/null

echo "Check above build logs and below build artifacts and then run required deploy jobs...\n"
exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/$dtout

### Logging New Package to details
### Get latest version info
pkg_ver=`awk -F"EP|CI|CB|TO|NA|UB" '/Marking SVN builds version/ {gsub(/\./,"");print $2}' ${logpath}/build_pass2.log`
awk -F":" -v ss="${pkg_ver}" '$0 ~ ss {print $2}' ${logpath}/build_pass2.log | sort | uniq  > ${logpath}/pkg_info

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
  echo "BUILD FAILED, please check for ERROR in the build logs on DMS"
  exit 1
else
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
