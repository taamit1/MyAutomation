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

## Removing old jar from svn location
if [ -f ${svnpath}/*.jar ]
then
	echo "Removing old Jar from ${svnpath} ......."
	rm ${svnpath}/*.jar
fi

## extracting packages to svn location
cd ${svnpath}
echo "------------------------------------------------------"
if [ -f ${pkgpath}/*.jar ] || [ -f ${pkgpath}/*.zip ]
then
	for jrs in ${pkgpath}/*.jar ${pkgpath}/*.zip
	do
	   if [ -f ${jrs} ]
	   then
		echo "Extracting ${jrs} ... \n"
		jar -xf ${jrs}
		if [ $? -eq 0 ]
		then
			mv ${jrs} ${pkgpath}/${dt}/
		else
			echo "ERROR EXTRACTING ${jrs} CANNOT PROCEED FURTHER ....."
			#exit 2
		fi
	   fi
	done
else
	echo "WARNING: No jar or custom package relesed for this build ...."
fi

## copy patch.list if required
if [ -f ${pkgpath}/patch.list ]
then
	echo "Copying patch.list .... \n"
	perl -p -i -e 's/\r//g' ${pkgpath}/patch.list
	cp ${pkgpath}/patch.list ${svnpath}/S1-INSTALL-INF/
	mv ${pkgpath}/patch.list ${pkgpath}/${dt}/
else
	echo "No patch.list relesed for this build ...."

fi

if [ -f ${pkgpath}/*.patch ]
then
      echo "Copying the core patches under ${patchpath}..."
      echo *.patch
      cp -p ${pkgpath}/*.patch ${patchpath}/.
      if [ $? -eq 0 ]
      then
        echo "Successfully copied the core patches."
      else
         echo "ERROR while copying the core patches, check on DMS server..."
         #exit 3
      fi
      rm ${pkgpath}/*.patch
fi

###### deleting files as per filedelete.list if required --- danger
#if [ -f ${pkgpath}/filedelete.list ]
#then
	#echo "Deleting files asper filedelete.list .... \n"
	#perl -p -i -e 's/^\s*$//g'  ${pkgpath}/filedelete.list ###removing blnk lines if any
	#perl -p -i -e 's/\r//g' ${pkgpath}/filedelete.list
	#cat ${pkgpath}/filedelete.list |  while read li
	#do
		#if [ -f ${svnpath}/${li} ]
		#then
			#echo "Deleting file ${svnpath}/${li}"
			#rm -rf ${svnpath}/${li}
		#else
			#echo " ${svnpath}/${li} Does not Exists "
		#fi
	#done
#else
	#echo "No filedelete.list relesed for this build ...."

#fi

## Removing CTRL+M character from files
echo "------------------------------------------------------------"
echo "Removing ^M character ..."

find ${svnpath}/ -name '*.jsp' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.sql' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.db2' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.xml' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.xmi' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.css' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.htm' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.html' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.pl' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.list' -exec perl -i -pe 's/\r//g' {} \;
find ${svnpath}/ -name '*.txt' -exec perl -i -pe 's/\r//g' {} \;

## Removing META-INF Folder
if [ -d ${svnpath}/META-INF ]
then
	rm -rf ${svnpath}/META-INF
	if [ ! $? -eq 0 ]
	then
		echo "Could not delete ${svnpath}/META-INF Proceeding .... "
	else
		echo "Deleted ${svnpath}/META-INF Proceeding .... "
	fi
fi

#echo "\nChanging the timestamp for all files under custom to"
#echo "current timestamp to resolve a bug in EnvMgr..."
#touch mynewfile
#for file in `find .|egrep -v '.svn|~'`
#do
 #touch -r mynewfile $file
#done
#rm mynewfile

## Running test Build
echo "------------------------------------------------------------"
echo "Checking File Change/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
/tmp/uA${random} test
rm /tmp/uA${random}

#exit 0
