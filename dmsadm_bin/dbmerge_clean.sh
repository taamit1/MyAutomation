#
#
#

if test $# -ne 1
then
  echo "Usage: $0 FI1"
  exit 1
fi

SRCFI1=$1

DBINSTDIR=/platform/$SRCFI1/s1env/EP/custom/database/install
if test ! -d $DBINSTDIR
then
  echo "ERROR: $DBINSTDIR not found"
  exit 2
fi

DBMIGDIR=/platform/EP3.5.2.0H0/EP/Banking/database/migration
if test ! -d $DBINSTDIR
then
  echo "ERROR: $DBINSTDIR not found"
  exit 2
fi

SRCFILES1=/tmp/sf1$$
>$SRCFILES1
TGTFILES=/tmp/tf$$
>$TGTFILES

find $DBINSTDIR -type f |sed -e "s?$DBINSTDIR/??" |sort >>$SRCFILES1

CWD=`pwd`

echo "Processing $SRCFI1 only files ..."
cd $DBINSTDIR
for FNAM in `cat $SRCFILES1`
do
  if test -s $DBMIGDIR/$FNAM
  then
    rm $FNAM
  fi
done

rm -f $SRCFILES1 $TGTFILES
