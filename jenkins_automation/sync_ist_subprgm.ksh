FIID=$1
VBUILD=$2
PRODNAME=$3
islocpath=$4
isuobpath=$5
dt=$6

temploc="/tmp/${FIID}/${dt}/${VBUILD}"
mkdir -p ${temploc} 2>/dev/null
if [ $? -eq 0 ]
then
  cd ${temploc}
  #SVN exporting the PROD V build to sync with
  echo "---------------------------------------------------------------------------------"
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

  echo "Export of PROD V build ${VBUILD} done..."
  echo "---------------------------------------------------------------------------------"
  #Syncing to SVN path
  echo "Syncing ${VBUILD} to ${islocpath}...\n"
  if [ ${PRODNAME} == "UOB" ]
  then
	  rsync -cbrv --delete --exclude=".svn/" INSTALL-INF/ ${isuobpath}/INSTALL-INF/
	  rsync -cbrv --delete --exclude=".svn/" actuate/ ${isuobpath}/actuate/
	  rsync -cbrv --delete --exclude=".svn/" ui/ ${isuobpath}/ui/
	  rsync -cbrv --delete --exclude=".svn/" database/ ${isuobpath}/database/
	  rsync -cbrv --delete --exclude=".svn/" j2se/ ${isuobpath}/j2se/
	  rsync -cbrv --delete --exclude=".svn/" j2ee/ ${isuobpath}/j2ee/
	  rsync -cbrv --delete --exclude=".svn/" patch/ ${isuobpath}/patch/
  else
  	  rsync -cbrv --delete --exclude=".svn/" S1-INSTALL-INF/ ${islocpath}/S1-INSTALL-INF/
	  rsync -cbrv --delete --exclude=".svn/" actuate/ ${islocpath}/actuate/
	  rsync -cbrv --delete --exclude=".svn/" ui/ ${islocpath}/ui/
	  rsync -cbrv --delete --exclude=".svn/" database/ ${islocpath}/database/
	  rsync -cbrv --delete --exclude=".svn/" j2se/ ${islocpath}/j2se/
	  rsync -cbrv --delete --exclude=".svn/" j2ee/ ${islocpath}/j2ee/
	  rsync -cbrv --delete --exclude=".svn/" filedrop/ ${islocpath}/filedrop/
	  rsync -cbrv --delete --exclude=".svn/" patch/ ${islocpath}/patch/
  fi
 echo "Syncing of ${VBUILD} to ${islocpath} done...\n"
 echo "-----------------------------------------------------------------------"
 echo "\nDeleting temp location ${temploc}...\n"
 rm -rf ${temploc}

else
  echo "\nCouldn't create temp DIR ${temploc}, check on DMS for required permissions for IST instance on temp DIR...\n"
  exit 1
fi
