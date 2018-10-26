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

###### Removing old zip from svn location
if [ -f ${srcpath}/*.zip ]
then
	echo "Removing old Jar from ${srcpath} ......."
	rm ${srcpath}/*.zip
fi

###### extracting packages to svn location
cd ${pkgpath}
echo "------------------------------------------------------"
echo "Preparing the sync directory..."
rm -rf ${pkgpath}/EP

if [ -f ${pkgpath}/*.zip ]
then
	for jrs in ${pkgpath}/*.zip
	do
	   if [ -f ${jrs} ]
	   then
		echo "Extracting DMS Zip ${jrs}... \n"
		unzip -o ${jrs} -x EP/CBInternational/S1-INSTALL-INF/*.xml EP/CBInternational/j2ee/server/cfg/*.ini >>/dev/null 2>&1
		if [ $? -eq 0 ]
		then
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
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/CBInternational/j2ee/ ${svnpath}/j2ee/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/CBInternational/S1-INSTALL-INF/ ${svnpath}/S1-INSTALL-INF/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/CBInternational/j2se/ ${svnpath}/j2se/
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/CBInternational/actuate/ ${svnpath}/actuate/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/CBInternational/database/ ${svnpath}/database/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/CorporateBanking/database/ ${svnpath}/database/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/CBInternational/ui/ ${svnpath}/ui/
else
	echo "No ${pkgpath}/EP found, so no need to sync.. \n"
fi

if [ -f ${pkgpath}/*.patch ]
then
      echo "\nCopying the core patches under ${patchpath}..."
      cp -p ${pkgpath}/*.patch ${patchpath}/.
      if [ $? -eq 0 ]
      then
        echo "Successfully copied the core patches."
      else
         echo "ERROR while copying the core patches, check on DMS server..."
         #exit 1
      fi
      rm ${pkgpath}/*.patch
fi

#echo "Removing the sync directory..."
rm -rf ${pkgpath}/EP

echo "------------------------------------------------------"
###### Removing CTRL+M character from files
echo "Removing ^M characters from files ... \n"
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

## Running test Build
echo "------------------------------------------------------"
echo "Checking files Changed/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
/tmp/uA${random} test
rm /tmp/uA${random}

exit 0
