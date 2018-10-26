FIID=$1
VBUILD=$2
PRODNAME=$3
svnpath=$4
uobsvnpath=$5
dt=$6

temploc="/tmp/${FIID}/${dt}/${VBUILD}"
mkdir -p ${temploc} 2>/dev/null
if [ $? -eq 0 ]
then
  cd ${temploc}
  #SVN exporting the PROD V build to revert back
  echo "\nExporting the PROD V build ${VBUILD} to temp location ${temploc} on DMS...\n"

  if [ ${PRODNAME} == "UOB" ]
  then
	svn export file:///dms/${FIID}/builds/${VBUILD}/INSTALL-INF >/dev/null 2>&1
  else
	svn export file:///dms/${FIID}/builds/${VBUILD}/S1-INSTALL-INF >/dev/null 2>&1
	svn export file:///dms/${FIID}/builds/${VBUILD}/filedrop >/dev/null 2>&1
  fi

  svn export file:///dms/${FIID}/builds/${VBUILD}/ui >/dev/null 2>&1
  svn export file:///dms/${FIID}/builds/${VBUILD}/actuate >/dev/null 2>&1
  svn export file:///dms/${FIID}/builds/${VBUILD}/database >/dev/null 2>&1
  svn export file:///dms/${FIID}/builds/${VBUILD}/j2se >/dev/null 2>&1
  svn export file:///dms/${FIID}/builds/${VBUILD}/j2ee >/dev/null 2>&1
  svn export file:///dms/${FIID}/builds/${VBUILD}/patch >/dev/null 2>&1

  echo "Export of build ${VBUILD} done..."
  echo "---------------------------------------------"

  #Syncing to SVN path
  echo "Syncing ${VBUILD} to ${svnpath}...\n"
  if [ ${PRODNAME} == "UOB" ]
  then
	  rsync -cbrv --delete --exclude=".svn/" INSTALL-INF/ ${uobsvnpath}/INSTALL-INF/
	  rsync -cbrv --delete --exclude=".svn/" actuate/ ${uobsvnpath}/actuate/
	  rsync -cbrv --delete --exclude=".svn/" ui/ ${uobsvnpath}/ui/
	  rsync -cbrv --delete --exclude=".svn/" database/ ${uobsvnpath}/database/
	  rsync -cbrv --delete --exclude=".svn/" j2se/ ${uobsvnpath}/j2se/
	  rsync -cbrv --delete --exclude=".svn/" j2ee/ ${uobsvnpath}/j2ee/
	  rsync -cbrv --delete --exclude=".svn/" patch/ ${uobsvnpath}/patch/
  else
  	  rsync -cbrv --delete --exclude=".svn/" S1-INSTALL-INF/ ${svnpath}/S1-INSTALL-INF/
	  rsync -cbrv --delete --exclude=".svn/" actuate/ ${svnpath}/actuate/
	  rsync -cbrv --delete --exclude=".svn/" ui/ ${svnpath}/ui/
	  rsync -cbrv --delete --exclude=".svn/" database/ ${svnpath}/database/
	  rsync -cbrv --delete --exclude=".svn/" j2se/ ${svnpath}/j2se/
	  rsync -cbrv --delete --exclude=".svn/" j2ee/ ${svnpath}/j2ee/
	  rsync -cbrv --delete --exclude=".svn/" filedrop/ ${svnpath}/filedrop/
	  rsync -cbrv --delete --exclude=".svn/" patch/ ${svnpath}/patch/
  fi

  echo "Syncing of ${VBUILD} to ${svnpath} is done..."
  echo "-----------------------------------------------"

  echo "Checking files Changed/Modified/Deleted to revert back .... \n"
  random=`date +"%H%M%S"`
  if [ ${PRODNAME} == "UOB" ]
  then
	cp -p /platform/dmsadm/bin/useAntUB.sh /tmp/uA${random}
	chmod 755 /tmp/uA${random}
	perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
	/tmp/uA${random} test
	rm /tmp/uA${random}
  else
	cp -p /platform/dmsadm/bin/useAnt.sh /tmp/uA${random}
	chmod 755 /tmp/uA${random}
	perl -p -i -e 's/read ans/ans="n"/g' /tmp/uA${random}
	/tmp/uA${random} test
	rm /tmp/uA${random}
  fi

 echo "\nDeleting temp location ${temploc}..."
 echo "------------------------------------------"
 rm -rf ${temploc}

else
  echo "Couldn't create temp DIR ${temploc}, check on DMS for required permissions for DMSUSR on temp DIR...\n"
  exit 1
fi
