#!/usr/bin/ksh

fiid=$1
dt=$2
PRODNAME=$3
srcpath="/platform/${fiid}"
pkgpath="/packages/${fiid}"
svnpath="${srcpath}/s1env/EP/${PRODNAME}"

EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'V' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

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
                echo "Extracting the custom package ${jrs}..."
                unzip -o ${jrs} -x EP/${PRODNAME}/S1-INSTALL-INF/*.xml EP/${PRODNAME}/j2ee/server/cfg/*.ini >>/dev/null 2>&1
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
        echo "Syncing to SVN custom path ${svnpath}..."
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2ee/ ${svnpath}/j2ee/ >/dev/null 2>&1
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/filedrop/ ${svnpath}/filedrop/ >/dev/null 2>&1
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/S1-INSTALL-INF/ ${svnpath}/S1-INSTALL-INF/ >/dev/null 2>&1
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2se/ ${svnpath}/j2se/ >/dev/null 2>&1
       #rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/actuate/ ${svnpath}/actuate/ >/dev/null 2>&1
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/database/ ${svnpath}/database/ >/dev/null 2>&1
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/ui/ ${svnpath}/ui/ >/dev/null 2>&1
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${svnpath}/patch/ >/dev/null 2>&1
else
        echo "No ${pkgpath}/EP found, so no need to sync.."
fi

if [ -d ${pkgpath}/EP/${PRODNAME}/patch ]
then
        echo "Copying core patches to ${patchpath}..."
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${patchpath}/
fi

if [ -f ${pkgpath}/*.patch ]
then
      echo "Copying the core patches under ${patchpath}..."
      cp -p ${pkgpath}/*.patch ${patchpath}/.
      if [ $? -eq 0 ]
      then
        echo "Successfully copied the core patches."
      #else
         #echo "ERROR while copying the core patches, check on DMS server..."
         #exit 2
      fi
      rm ${pkgpath}/*.patch
fi

#echo "Removing the sync directory..."
rm -rf ${pkgpath}/EP

## Removing CTRL+M character from files
echo "------------------------------------------------------------"
echo "Removing ^M character ..."
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
echo "------------------------------------------------------------"
echo "Checking File Change/Modified/Deleted for the package .... \n"

random=`date +"%H%M%S"`
cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
chmod 755 /tmp/uA${random}
perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
/tmp/uA${random} test
rm /tmp/uA${random}

#exit 0
