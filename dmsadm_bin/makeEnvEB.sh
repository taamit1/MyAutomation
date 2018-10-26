#
# makeEnv.sh
#
ADMUSER="dmsadm"
REPO_ROOT="/dms"

PATH=$PATH:/usr/local/bin

EP_VER_FILE="$HOME/.ep_ver"
EP_VAL_FILE=/platform/$ADMUSER/bin/makeEnv.dat

LOGFILE="/platform/$ADMUSER/$ADMUSER.log"
FINAME=`echo $LOGNAME|sed -e "s/^dms/fi/" |sed -e "s/^dm/fi/" |sed -e "s/^env/fi/"`
LOGINUSER=`who am i |cut -f1 -d' '`

#
# SVN tasks
#
umask 002
SVN_CREATED="N"

groups | grep "svngrp" >>/dev/null 2>&1
if test $? -ne 0
then
  echo "Error: This user must belong to the svngrp group before continuing."
  echo "       Contact an AIX administrator to have this user added to svngrp group"
  exit 2
fi

####
# BASE version setup
####
echo
echo "1)EB1.0"
echo "Select EB Base Version: \c"
read verch

case "$verch" in
     1) PRODBASE="EB1.0"
        PRODNAME="EBDCOS"
        SVCPDESC="Release"
        SVCPDEF="0"
        FIXPDEF="0"
      ;;
  *) echo "Invalid selection."
     exit 1
  ;;
esac


# check for repo
if test ! -s $REPO_ROOT/$FINAME/format  # try to create repo for FI
then
  echo "Creating SubVersion repository for $FINAME"
  svnadmin create $REPO_ROOT/$FINAME
  if test $? -eq 0
  then
    # fix perm bug in svn
    chmod g+w $REPO_ROOT/$FINAME/db/rep-cache.db

    svn mkdir file://$REPO_ROOT/$FINAME/trunk -m "Maintain custom development"
    if test $? -ne 0
    then
      echo "Error: svn failed to mkdir file://$REPO_ROOT/$FINAME/trunk"
      exit 2
    fi
    svn mkdir file://$REPO_ROOT/$FINAME/builds -m "Tag all build versions"
    if test $? -ne 0
    then
      echo "Error: svn failed to mkdir file://$REPO_ROOT/$FINAME/builds"
      exit 2
    fi
    svn mkdir file://$REPO_ROOT/$FINAME/branches -m "Branches for version specific releases"
    if test $? -ne 0
    then
      echo "Error: svn failed to mkdir file://$REPO_ROOT/$FINAME/branches"
      exit 2
    fi
    SVN_CREATED="Y"
  else
    echo "Error: svnadmin create failed.  Contact support"
    exit 2
  fi
  echo
fi


#
# gather env version
#
echo "Current Application version selected: $PRODBASE"

#
# get Release version?
#
echo
echo "Enter $SVCPDESC version (default is $SVCPDEF)? \c"
read PRODSVCP
[ -z "$PRODSVCP" ] && PRODSVCP="$SVCPDEF"
echo "Current version is $PRODBASE.$PRODSVCP"

#
# get Fixpack version?
#
echo
echo "Enter FixPack version (default is $FIXPDEF)? \c"
read PRODFIXP
[ -z "$PRODFIXP" ] && PRODFIXP="$FIXPDEF"
echo "Current version is $PRODBASE.$PRODSVCP.$PRODFIXP"

#
# get HotFix version?
#
echo
echo "Enter HotFix version (default is 0)? \c"
read PRODHOTF
[ -z "$PRODHOTF" ] && PRODHOTF="0"

EP_VER="${PRODBASE}.${PRODSVCP}.${PRODFIXP}H${PRODHOTF}"

PRODDIR="/platform/$EP_VER"
echo "Setting up for version `basename $PRODDIR` ..."

if test ! -d $PRODDIR/EP
then
  if test -s $PRODDIR/.ep_ver
  then
    echo "Product directory $PRODDIR/EP is OFF-LINE"
    exit 1
  else
    echo "Product directory $PRODDIR/EP does NOT exist"
    exit 1
  fi
fi

#
# validate fi can use version
#
if test -s $EP_VAL_FILE
then
  VALID_FIS=`cat $EP_VAL_FILE|egrep -e "^$PRODDIR " |awk '{print $2}'`
  if test "$VALID_FIS" = "ALL"
  then
    echo
  elif test "$VALID_FIS" = "NONE" -o "$VALID_FIS" = ""
  then
    echo "$PRODDIR has not been released for use"
    exit 2
  else
    echo "$VALID_FIS"|grep "$LOGNAME" >>/dev/null 2>&1
    if test $? -ne 0
    then
      echo "User $LOGNAME is not authorized to use $PRODDIR"
      exit 2
    fi
  fi
else
  echo
fi

cd $HOME

if test -d $HOME/EP
then
  echo "$HOME/EP already exists"
  echo "Resetting old environment ..."
#BV  rm -rf $HOME/EP/$PRODNAME
#BV  rm -rf $HOME/EP/Actuate
  rm -rf $HOME/EP/INSTALL-INF
  rm -rf $HOME/EP/build
  rm -rf $HOME/workspace.old
  mv -f $HOME/workspace $HOME/workspace.old 2>>/dev/null
else
  mkdir $HOME/EP
  if test $? -ne 0
  then
    echo "mkdir failed.  Can not continue."
    exit 2
  fi
  rm -rf $HOME/workspace.old
  mv -f $HOME/workspace $HOME/workspace.old 2>>/dev/null
fi
cd $HOME/EP

#
# make other DB2 directories
#
for FNAM in $HOME/DB2_Exports $HOME/DB2_Scripts
do
  if test ! -d $FNAM    # if it doesn't exist than make it
  then
    mkdir $FNAM
  fi
  chgrp db2asgrp $FNAM 2>>/dev/null
  chmod g+sw $FNAM
done

#
# make EP level dirs/links
#
#BV ln -s $PRODDIR/EP/Actuate
mkdir build
#BV mkdir $PRODNAME
mkdir INSTALL-INF
cp -p $PRODDIR/EP/INSTALL-INF/* INSTALL-INF/
# add CoreEnvPath to environment.xml
ed INSTALL-INF/environment.xml >>/dev/null 2>&1 <<EOS
/product uri
d
i
    <product uri="$PRODNAME" coreEnvPath="$PRODDIR/EP"/>
.
w
q
EOS

#
# custom
#
if test ! -d $PRODNAME
then
  if test "$SVN_CREATED" = "N"
  then
    svn co file://$REPO_ROOT/$FINAME/trunk $PRODNAME
  else
    mkdir $PRODNAME
    cd $HOME/EP/$PRODNAME
    mkdir INSTALL-INF
    touch INSTALL-INF/custom.patch.list
    mkdir patch
    cp -p $PRODDIR/EP/$PRODNAME/INSTALL-INF/product-state.xml INSTALL-INF/
    cp -p $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xml INSTALL-INF/
    mkdir -p database/install
    mkdir -p j2ee/server
    mkdir -p j2ee/ear
    mkdir -p j2se/batch/bci
    mkdir -p epmedia/user
    mkdir -p epmedia/sam
    ####
    # get customizations from version control
    ####
    echo "restore any customizations to `pwd`"
    echo "  (including product-state.xml to $PRODNAME/INSTALL-INF)"
    echo
  fi
else
  echo "using existing `pwd` files"
  echo "  (including product-state.xml in $PRODNAME/INSTALL-INF)"
  echo
fi

cd $HOME/EP/$PRODNAME/INSTALL-INF
#BV ln -sf $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xml
#BV ln -sf $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xsd

#
# do initial import into svn repo if we just created it
#    and set props in ~/.subversion/config
#
if test "$SVN_CREATED" = "Y"
then
  # enable auto-props/and eol=native
  if test -w $HOME/.subversion/config
  then
    ed $HOME/.subversion/config >>/dev/null 2>&1 <<EOS
/^\[miscellany
a
enable-auto-props = yes
.
/^\[auto-props
a
*.properties = svn:eol-style=native
*.sh = svn:eol-style=native
*.ksh = svn:eol-style=native
*.kshlib = svn:eol-style=native
*.bat = svn:eol-style=native
*.xml = svn:eol-style=native
*.mkelem = svn:eol-style=native
*.xsl = svn:eol-style=native
*.xsd = svn:eol-style=native
*.txt = svn:eol-style=native
*.awk = svn:eol-style=native
*.conf = svn:eol-style=native
*.sql = svn:eol-style=native
*.csv = svn:eol-style=native
*.jsp = svn:eol-style=native
*.js = svn:eol-style=native
*.java = svn:eol-style=native
*.ini = svn:eol-style=native
*.MF = svn:eol-style=native
*.htm = svn:eol-style=native
*.html = svn:eol-style=native
*.jacl = svn:eol-style=native
*.css = svn:eol-style=native
*.cfg = svn:eol-style=native
.
w
q
EOS
  fi
  #
  cd $HOME/EP
  echo "Initial import of custom files ...."
  svn -q --no-auto-props import $PRODNAME/ file://$REPO_ROOT/$FINAME/trunk -m"Initial import of custom files"
  if test $? -ne 0
  then
    echo "****"
    echo "Warning: svn import failed.  Continuing"
    echo "****"
  else
    svn copy file://$REPO_ROOT/$FINAME/trunk file://$REPO_ROOT/$FINAME/builds/makeEnv -m"Initial import by makeEnv.sh"
    svn copy file://$REPO_ROOT/$FINAME/trunk file://$REPO_ROOT/$FINAME/branches/$EP_VER -m"$EP_VER"
    rm -rf $PRODNAME.presvn
    mv -f $PRODNAME $PRODNAME.presvn
    svn checkout file://$REPO_ROOT/$FINAME/branches/$EP_VER $PRODNAME
    if test $? -ne 0
    then
      echo "****"
      echo "Warning: svn checkout failed.  Continuing"
      echo "         resetting custom directory"
      echo "****"
      mv -f $PRODNAME $PRODNAME.failsvn
      mv -f $PRODNAME.presvn $PRODNAME   # reset to original custom & continue
    else
      cd $HOME/EP/$PRODNAME
      svn update
      echo "Custom files checked out from branch $EP_VER"
    fi
  fi
fi

#
# Handle PRODUCT directory
#
cd $HOME/EP/$PRODNAME

#BV ln -s $PRODDIR/EP/$PRODNAME/j2se
#BV ln -s $PRODDIR/EP/$PRODNAME/database
#BV ln -s $PRODDIR/EP/$PRODNAME/docs
#BV ln -s ../custom/INSTALL-INF


#ln -s $PRODDIR/EP/$PRODNAME/ui  - need individual files links
#BV cd $HOME/EP/$PRODNAME
#BV mkdir ui
#BV cd ui
#BV mkdir INSTALL-INF
#BV cd INSTALL-INF
#BV for NAM in `ls $PRODDIR/EP/$PRODNAME/ui/INSTALL-INF`
#BV do
#BV   ln -s $PRODDIR/EP/$PRODNAME/ui/INSTALL-INF/$NAM
#BV done
#BV ln -sf ../../../custom/ui/INSTALL-INF/customizations-presentation.xml


#ln -s $PRODDIR/EP/$PRODNAME/j2ee  - need individual files links
#BV cd $HOME/EP/$PRODNAME
#BV mkdir j2ee
#BV cd j2ee
#BV ln -s $PRODDIR/EP/$PRODNAME/j2ee/server
#BV mkdir ear
#BV cd ear
#BV for NAM in `ls $PRODDIR/EP/$PRODNAME/j2ee/ear`
#BV do
#BV   ln -s $PRODDIR/EP/$PRODNAME/j2ee/ear/$NAM
#BV done
#BV rm -f INSTALL-INF
#BV mkdir INSTALL-INF
#BV cd INSTALL-INF
#BV for NAM in `ls $PRODDIR/EP/$PRODNAME/j2ee/ear/INSTALL-INF`
#BV do
#BV   ln -s $PRODDIR/EP/$PRODNAME/j2ee/ear/INSTALL-INF/$NAM
#BV done
#BV ln -s ../../../../custom/j2ee/ear/INSTALL-INF/customizations.xml
#BV ln -s ../../../../custom/j2ee/ear/INSTALL-INF/customizations-actions.xml

#
# build
#
#BV cd $HOME/EP/build
#BV mkdir INSTALL-INF
#BV cd INSTALL-INF
#BV ln -s ../../custom/INSTALL-INF/product-state.xml
#BV cd ..
#BV mkdir -p j2ee/server
#BV mkdir -p j2ee/ear
#BV mkdir -p j2se/batch/bci
#BV ln -s ../$PRODNAME/ui

#
# get/set version
#
if test -s $EP_VER_FILE
then
  EP_VER_CUR=`awk '{print $2}' $EP_VER_FILE |grep "${EP_VER}V" |tail -1`
  if test "$EP_VER_CUR" = ""
  then
    EP_VER_FI="${EP_VER}V0"
  else
    EP_VER_FI=`echo $EP_VER_CUR |awk '{if (index($1,"V") == 0) {s=$1;v=0} else{s=substr($1,0,index($1,"V") - 1);v=substr($1,index($1,"V") + 1)} ;print s "V" v}'`
  fi
else
  EP_VER_FI="${EP_VER}V0"
fi
EP_VER_SHORT=`echo $EP_VER_FI |sed -e "s/EP//" -e "s/\.//g"`

#
# svn checkout & tag builds
#
if test "$SVN_CREATED" = "N"  # must switch to or create a branch
then
  svn -q --limit 1 log file://$REPO_ROOT/$FINAME/branches/$EP_VER >>/dev/null 2>&1
  if test $? -eq 0
  then
    # found the branch version so lets update custom
    echo "Switching custom branch to $EP_VER ..."
    cd $HOME/EP/$PRODNAME
    svn switch file://$REPO_ROOT/$FINAME/branches/$EP_VER
    if test $? -ne 0
    then
      echo "****"
      echo "Warning: svn switch failed.  Research error before continuing"
      echo "****"
    else
      cd $HOME/EP/$PRODNAME
      svn update
      echo "Custom files switched to branch $EP_VER"
    fi
  else
    # branch was not found so use what is in custom
    echo "Creating new custom branch for $EP_VER ..."
    cd $HOME/EP/$PRODNAME
    CUR_BRANCH=`svn -v --stop-on-copy log |grep -v "^\-" | tail -1`
    if test "$CUR_BRANCH" = "Maintain custom development"
    then
      svn copy file://$REPO_ROOT/$FINAME/trunk file://$REPO_ROOT/$FINAME/branches/$EP_VER -m"$EP_VER"
    else
      svn copy file://$REPO_ROOT/$FINAME/branches/$CUR_BRANCH file://$REPO_ROOT/$FINAME/branches/$EP_VER -m"$EP_VER"
    fi
    svn switch file://$REPO_ROOT/$FINAME/branches/$EP_VER
    if test $? -ne 0
    then
      echo "****"
      echo "Warning: svn switch failed.  Research error before continuing"
      echo "****"
    else
      cd $HOME/EP/$PRODNAME
      svn update
      echo "Custom files switched to branch $EP_VER"

      # change symlink to file for product.xml
      if test -h INSTALL-INF/product.xml
      then
        rm -f INSTALL-INF/product.xml
        svn rm INSTALL-INF/product.xml
        svn ci INSTALL-INF/product.xml -m"remove symlink for product.xml"
      fi
      # copy in current product.xml
      cp $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xml INSTALL-INF/product.xml
    fi
  fi
fi


cd $HOME/EP/$PRODNAME
# create empty "custom" tab if it does not exist
if test ! -s ui/INSTALL-INF/customizations-presentation.xml
then
  mkdir -p ui/INSTALL-INF
  touch ui/INSTALL-INF/customizations-presentation.xml
 cat - >ui/INSTALL-INF/customizations-presentation.xml <<EOF
<component-fragment name="Custom Env Mgr UI Tabs and Properties" xmlns="urn://s1.com/ia/component-fragment">

   <description>This fragment describes the Environment Manager UI Custom properties and tabs</description>

<!-- UI GROUPS -->
          <!-- Custom -->
          <property-ui-groups>
                    <id>custom</id>
                    <tab-name>Custom</tab-name>
                    <full-name>Custom Items</full-name>
                    <description>Setup of Application Custom Items</description>
                    <display-position>999999</display-position>
          </property-ui-groups>

          <actions uri="no-actions.xml"/>

</component-fragment>
EOF
fi

# changes for version 48.3 of EnvMgr
# create server directory if it does not exist
if test ! -d j2ee/server
then
  mkdir -p j2ee/server
fi
# change symlink to file for product.xml
if test -h INSTALL-INF/product.xml
then
  rm -f INSTALL-INF/product.xml
  svn rm INSTALL-INF/product.xml
  svn ci INSTALL-INF/product.xml -m"remove symlink for product.xml"
  cp $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xml INSTALL-INF/product.xml
fi
# create product-xml if it is missing
if test ! -s INSTALL-INF/product.xml
then
  cp $PRODDIR/EP/$PRODNAME/INSTALL-INF/product.xml INSTALL-INF/product.xml
fi
# remove symlink for file product.xsd
if test -h INSTALL-INF/product.xsd
then
  rm -f INSTALL-INF/product.xsd
  svn rm INSTALL-INF/product.xsd
  svn ci INSTALL-INF/product.xsd -m"remove symlink for product.xsd"
fi

#
# display warnings about patch method changes that may be required
#



echo "Setup $EP_VER_FI for $HOME/EP on `date`" |tee -a $EP_VER_FILE
echo "$0 is complete"
echo "$LOGINUSER is running makeEnv as $LOGNAME for $FINAME on <$EP_VER_FI> @ `date`" >>$LOGFILE
exit 0
