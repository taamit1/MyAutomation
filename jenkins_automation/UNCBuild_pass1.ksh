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
#dmgr_node=$2
idfi=`echo ${fiid#??}`
dt=`date +"%d%b%Y%H%M%S"`
dt1=`date +"%d-%b-%Y"`

srcpath="/platform/${fiid}"
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
        if test ! -d ${srcpath}/s1env/EP/$PRODNAME
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
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'V' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

# check if core patch folder is writable for dmsusr
if ls -ld ${patchpath}|grep -q ^drwxrwxr-x >/dev/null 2>&1
then
  continue
else
  chmod -R 775 ${patchpath} >/dev/null 2>&1
fi

echo "------------------------------------------------------"
date;echo

## Checking if build is triggered by mistake
if [ ! -f ${pkgpath}/*.zip ] && [ ! -f ${pkgpath}/*.list ]
then
        echo "************************************************************************"
        echo "WARNING: There is no custom zip package found under /packages/${fiid}   "
        echo "on DMS (epdms01), So CONTINUING without the custom package for ${fiid}  "
        echo "You can run Pass2 job to create EAR/JAR without new custom build.       "
        echo "************************************************************************"
        #exit 0
fi

mkdir ${logpath}
echo ${dt} > ${pkgpath}/blddtl
if [ ! -f ${pkgpath}/old_blddtl ]
then
        touch ${pkgpath}/old_blddtl
fi

## This is for logging intelegance
mkfifo ${logpath}/out.pipe
exec 3>&1 4>&1
tee ${logfile} < ${logpath}/out.pipe >&3 &
pid_out=$!
exec  1>${logpath}/out.pipe
exec  2>${logpath}/out.pipe

chown -R ${dmsusr}.staff ${logpath} >>/dev/null 2>&1
chown ${dmsusr}.staff *.* >>/dev/null 2>&1

echo "Cleaning up Package Upload Directory from ${pkgpath} "
no_dir=`wc -l ${pkgpath}/old_blddtl | awk '{print $1}'`
if [ ${no_dir} -gt 5 ]
then
	no_head=$((${no_dir}-5))
	for fldr in `head -${no_head} ${pkgpath}/old_blddtl`
	do
		if [ -d ${pkgpath}/${fldr} ]
		then
			echo  "Deleting Package Folder ${pkgpath}/$fldr"
			rm -rf ${pkgpath}/${fldr}
		fi
	done
	#head  -${no_head} ${pkgpath}/blddtl >> ${pkgpath}/audit_blddtl
	tail -5 ${pkgpath}/old_blddtl > ${pkgpath}/old_blddtl.tmp
	mv  ${pkgpath}/old_blddtl.tmp ${pkgpath}/old_blddtl

else
	echo "Nothing to clean UP in ${pkgpath} "
fi

PKGCNT=`ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|wc -l`
if [ ${PKGCNT} -gt 6 ]
then
  echo "Removing old DIRs from Package Upload DIR..."
  ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>6'|xargs rm -rf 2>/dev/null
fi

echo "------------------------------------------------------"
sudo su - $dmsusr -c " ${cwd}/UNCsubprgm_pass1.ksh ${fiid} ${dt}" 2>/dev/null

echo "Check mail to verify the changes and then run Pass2 "
exec 1>&3 3>&- 2>&4 4>&-
wait $pid_out
rm ${logpath}/out.pipe

## Composing delta e-mail
echo "Hello,\nPlease verify build package.\n" > ${logpath}/tmp
echo "Build date : "`date +"%d-%b-%Y"`"\n" >> ${logpath}/tmp
awk -F":" '/SVN has found/ {print "Build evaluation : "$2}' ${logfile} >> ${logpath}/tmp
echo "\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##  Files Modified  ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^[mM]/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##   Files Added    ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^\?/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n" >> ${logpath}/tmp

echo "######################" >> ${logpath}/tmp
echo "##  Files Deleted   ##" >> ${logpath}/tmp
echo "######################" >> ${logpath}/tmp
awk '/^\!/ {print "\t"$2}' ${logfile} >> ${logpath}/tmp
echo "\n" >> ${logpath}/tmp

mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" ramesh.bollempalli@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" bud.cook@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" Divya.Rajendran@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" ray.spiva@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" sharon.telljohn@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" joseph.thompson@aciworldwide.com < ${logpath}/tmp

mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" Qamar.Khan@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" amit.tarwade@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Build Verification for ${fiid}" pallavi.kulkarni@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Delta files Verification for ${fiid}" sureshkumar.karajada@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Delta files Verification for ${fiid}" pankaj.zarekar@aciworldwide.com < ${logpath}/tmp
mail -r "dmsbuild@bankonline.com"  -s "Delta files Verification for ${fiid}" narendra.edupuganti@aciworldwide.com < ${logpath}/tmp

mail -r "dmsbuild@bankonline.com"  -s "Delta files Verification for ${fiid}" EPOperationsSystemEngandAdminTeam@aciworldwide.com < ${logpath}/tmp

rm ${logpath}/tmp

exit 0
