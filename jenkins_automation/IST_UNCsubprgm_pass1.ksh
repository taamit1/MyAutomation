#!/usr/bin/ksh

fiid=$1
dt=$2
srcpath="/istplatform/${fiid}"
pkgpath="/packages/${fiid}"

PRODNAME="CorporateBanking"

svnpath="${srcpath}/s1env/EP/${PRODNAME}"
EP_VER_FILE="${srcpath}/.ep_ver"
EP_VER_CUR=`tail -1 $EP_VER_FILE|awk '{print $2}'|awk -F'T' '{print $1}'`
corepath="/platform/$EP_VER_CUR"
patchpath="${corepath}/EP/${PRODNAME}/patch"

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
                        #exit 1
                fi
           fi
        done
else
        echo "No zip files released for this build ...."
fi

if [ -d ${pkgpath}/EP ]
then
        echo "Syncing to SVN custom path ${svnpath} with rsync.... \n"
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2ee/ ${svnpath}/j2ee/
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/S1-INSTALL-INF/ ${svnpath}/S1-INSTALL-INF/
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/j2se/ ${svnpath}/j2se/
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/actuate/ ${svnpath}/actuate/
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/database/ ${svnpath}/database/
        rsync -cbr --delete --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${svnpath}/patch/
	rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/ui/ ${svnpath}/ui/

	echo "Copying core patches to ${patchpath}..."
        rsync -cbr --exclude=".svn/" ${pkgpath}/EP/${PRODNAME}/patch/ ${patchpath}/
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

## Creating IST EAR/JAR
echo;echo "Creating the IST Package for Deployment..."
echo "-------------------------------------------------------------"
/usr/bin/sh S1buildApp.sh build-all
