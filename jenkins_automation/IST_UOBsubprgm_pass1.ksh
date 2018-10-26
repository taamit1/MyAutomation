#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/istplatform/${fiid}"
pkgpath="/packages/${fiid}"
svnpath="${srcpath}/EP/UOB"

logpath="${pkgpath}/${dt}"
logfile="${logpath}/ist_build_pass1.log"
EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'T' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
corebuildfile="${corepath}/EP/UOB/INSTALL-INF/build.properties"
patchpath="${corepath}/EP/UOB/patch"

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
rm -rf ${pkgpath}/EP

if [ -f ${pkgpath}/*.zip ]
then
	for jrs in ${pkgpath}/*.zip
	do
	   if [ -f ${jrs} ]
	   then
		echo "Extracting DMS Zip ${jrs}... \n"
		unzip -o ${jrs} -x EP/UOB/INSTALL-INF/product-state*.xml EP/UOB/j2ee/server/cfg/*.ini >>/dev/null 2>&1
		if [ $? -eq 0 ]
		then
			mv ${jrs} ${pkgpath}/${dt}
		else
			echo "ERROR EXTRACTING ${jrs} CANNOT PROCEED FURTHER ....."
			#exit 1
		fi
	   fi
	done
else
	echo "No zip files released for this build ...."
fi

if [ -d ${pkgpath}/EP ]
then
	echo "Syncing to the custom path ${svnpath}.... \n"
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/UOB/j2ee/ ${svnpath}/j2ee/ >/dev/null 2>&1
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/UOB/INSTALL-INF/ ${svnpath}/INSTALL-INF/ >/dev/null 2>&1
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/UOB/j2se/ ${svnpath}/j2se/ >/dev/null 2>&1
	rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/UOB/actuate/ ${svnpath}/actuate/ >/dev/null 2>&1
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/UOB/database/ ${svnpath}/database/ >/dev/null 2>&1
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/UOB/ui/ ${svnpath}/ui/ >/dev/null 2>&1
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
	 rm ${pkgpath}/*.patch
      else
         echo "ERROR while copying the core patches, check on DMS server..."
	 rm ${pkgpath}/*.patch
         #exit 2
      fi
fi

#echo "Removing the sync directory..."
rm -rf ${pkgpath}/EP

## Removing CTRL+M character from files
echo "------------------------------------------------------"
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
find . -name 'setupProfile' -exec perl -i -pe 's/\r//g' {} \;

# commenting out for SBNA eLearning content files timestamp conversion issue
#echo "Changing the timestamp for all files under custom to current timestamp to resolve a bug in EnvMgr..."
#touch mynewfile
#for file in `find .|egrep -v '.svn|~'`
#do
# touch -r mynewfile $file
#done
#rm mynewfile

echo "------------------------------------------------------"
echo "Creating IST Package for Deployment .... \n"
arlm buildApp -Dbuild.task=build-all -Denv.name=${fiid}
echo "------------------------------------------------------"

