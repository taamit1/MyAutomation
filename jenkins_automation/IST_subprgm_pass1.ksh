#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/istplatform/${fiid}"
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
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'T' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

echo "-------------------------------------------------------------";echo

## Removing old jar from custom location
if [ -f ${svnpath}/*.jar ]
then
	echo "Removing old Jar from ${svnpath} ......."
	rm ${svnpath}/*.jar
fi

## extracting packages to custom location
cd ${svnpath}
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
			exit 1
		fi
	   fi
	done
else
	echo "WARNING: No JAR or custom package relesed for this build...."
fi

echo "-------------------------------------------------------------"

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
      echo "\nCopying the core patches under ${patchpath}..."
      cp -p ${pkgpath}/*.patch ${patchpath}/.
      if [ $? -eq 0 ]
      then
        echo "Successfully copied the core patches."
      else
         echo
	 #echo "ERROR while copying the core patches, check on DMS server..."
         #exit 1
      fi
      rm ${pkgpath}/*.patch
fi

echo "-------------------------------------------------------------"

## Removing CTRL+M character from files
echo;echo "Removing ^M character ... \n"
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

## Removing META-INF folder
if [ -d ${svnpath}/META-INF ]
then
	rm -rf ${svnpath}/META-INF
	if [ ! $? -eq 0 ]
	then
	   echo "Could not delete ${svnpath}/META-INF Proceeding..."
	else
	   echo "Deleted ${svnpath}/META-INF Proceeding..."
	fi
fi

#echo;echo "Changing the timestamp for all files under custom to"
#echo "current timestamp to resolve a bug in EnvMgr..."
#touch mynewfile
#for file in `find .|egrep -v '.svn|~'`
#do
# touch -r mynewfile $file
#done
#rm mynewfile

## Creating IST EAR/JAR
echo;echo "Creating the IST Package for Deployment..."
echo "-------------------------------------------------------------"
/usr/bin/sh S1buildApp.sh build-all
