#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/platform/${fiid}"
pkgpath="/packages/${fiid}"

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
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'V' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

## Removing old zip from svn location
if [ -f ${srcpath}/*.zip ]
then
	echo "Removing old Jar from ${srcpath} ......."
	rm ${srcpath}/*.zip
fi

## extracting packages to svn location
cd ${pkgpath}
echo "------------------------------------------------------"
echo "Preparing the sync directory..."
rm -rf ${pkgpath}/EP ${pkgpath}/dist-dms 2>/dev/null

if [ -f ${pkgpath}/*.zip ]
then
	for jrs in ${pkgpath}/*.zip
	do
	   if [ -f ${jrs} ]
	   then
		echo "Extracting DMS Zip ${jrs}... \n"
		unzip -o ${jrs} -x dist-dms/EP/${PRODNAME}/S1-INSTALL-INF/*.xml dist-dms/EP/${PRODNAME}/j2ee/server/cfg/*.ini >>/dev/null 2>&1
		if [ $? -eq 0 ]
		then
			mv ${pkgpath}/dist-dms/EP ${pkgpath}/.
			mv ${jrs} ${pkgpath}/${dt}
		else
			echo "ERROR EXTRACTING ${jrs} CANNOT PROCEED FURTHER ....."
			exit 1
		fi
	   fi
	done
else
	echo "No zip files released for this build ...."
fi

if [ -d ${pkgpath}/EP ]
then
	echo "Syncing to SVN custom path ${svnpath}.... \n"
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2ee/ ${svnpath}/j2ee/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/S1-INSTALL-INF/ ${svnpath}/S1-INSTALL-INF/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2se/ ${svnpath}/j2se/
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/actuate/ ${svnpath}/actuate/
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/database/ ${svnpath}/database/
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${svnpath}/patch/
	echo "Copying core patches to ${patchpath}..."
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${patchpath}/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/ui/ ${svnpath}/ui/
else
	echo "No ${pkgpath}/EP found, so no need to sync.. \n"
fi

#echo "Removing the sync directory..."
rm -rf ${pkgpath}/EP ${pkgpath}/dist-dms 2>/dev/null

# COPY OVER DATABASE FILES for Unicredit CN/HK/SG/NY
echo "Copying over the database files for ${fiid}..."
cd ${svnpath}/database/install/S1-INSTALL-INF/
if [ ${fiid} == fi15654b ]
then
   for i in `ls *-CN.xml| awk -F "." '{print $1}'| awk -F "-CN" '{print $1}'`
   do cp $i-CN.xml $i.xml
   done
	elif [ ${fiid} == fi15654c ]
	then
		for i in `ls *-HK.xml| awk -F "." '{print $1}'| awk -F "-HK" '{print $1}'`
		do cp $i-HK.xml $i.xml
		done

		elif [ ${fiid} == fi15654d ]
		then
			for i in `ls *-SG.xml| awk -F "." '{print $1}'| awk -F "-SG" '{print $1}'`
			do cp $i-SG.xml $i.xml
			done
		elif [ ${fiid} == fi15654a ]
		then
			for i in `ls *-NY.xml| awk -F "." '{print $1}'| awk -F "-NY" '{print $1}'`
			do cp $i-NY.xml $i.xml
			done
		else
			echo "There is no need to copy over database files...\n"
fi

echo "------------------------------------------------------"
echo "Removing ^M characters from files..."
cd ${svnpath}

find . -name '*.jsp' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.js' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.sql' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.db2' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.xml' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.xsd' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.xmi' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.xsl' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.css' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.htm' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.html' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.pl' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.list' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.txt' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.tag' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.ksh' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.conf' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.rb' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.dtd' -exec perl -i -pe 's/\r//g' {} \;
find . -name '*.java' -exec perl -i -pe 's/\r//g' {} \;

echo "---------------------------------------------------------------"
echo "Checking files Changed/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
/tmp/uA${random} test
rm /tmp/uA${random}

exit 0
