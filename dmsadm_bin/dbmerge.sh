#
#
#

if test $# -ne 2
then
  echo "Usage: $0 FI1 FI2"
  exit 1
fi

SRCFI1=$1
SRCFI2=$2

DBINSTDIR=/platform/$SRCFI1/s1env/EP/custom/database/install
if test ! -d $DBINSTDIR
then
  echo "ERROR: $DBINSTDIR not found"
  exit 2
fi

DBINSTDIR=/platform/$SRCFI2/s1env/EP/custom/database/install
if test ! -d $DBINSTDIR
then
  echo "ERROR: $DBINSTDIR not found"
  exit 2
fi

SRCFILES1=/tmp/sf1$$
>$SRCFILES1
SRCFILES2=/tmp/sf2$$
>$SRCFILES2
TGTFILES=/tmp/tf$$
>$TGTFILES

DBINSTDIR=/platform/$SRCFI1/s1env/EP/custom/database/install
find $DBINSTDIR -type f |sed -e "s?$DBINSTDIR/??" |sort >>$SRCFILES1
DBINSTDIR=/platform/$SRCFI2/s1env/EP/custom/database/install
find $DBINSTDIR -type f |sed -e "s?$DBINSTDIR/??" |sort >>$SRCFILES2

CWD=`pwd`

echo "Processing $SRCFI1 only files ..."
cd /platform/$SRCFI1/s1env/EP/custom/database/install
comm -2 -3 $SRCFILES1 $SRCFILES2 |cpio -o >/tmp/dbfiles.$SRCFI1.cpio

echo "Processing $SRCFI2 only files ..."
cd /platform/$SRCFI2/s1env/EP/custom/database/install
comm -1 -3 $SRCFILES1 $SRCFILES2 |cpio -o >/tmp/dbfiles.$SRCFI2.cpio

echo "Processing COMMON files ..."
comm -1 -2 $SRCFILES1 $SRCFILES2 >$TGTFILES

>$TGTFILES.same
>$TGTFILES.diff
for FNAM in `cat $TGTFILES`
do
  # remove CRs before comparing
  cat /platform/$SRCFI1/s1env/EP/custom/database/install/$FNAM |sed -e "s/
$//" >/tmp/hf$$
  cp /tmp/hf$$ /platform/$SRCFI1/s1env/EP/custom/database/install/$FNAM

  cat /platform/$SRCFI2/s1env/EP/custom/database/install/$FNAM |sed -e "s/
$//" >/tmp/hf$$
  cp /tmp/hf$$ /platform/$SRCFI2/s1env/EP/custom/database/install/$FNAM

  cmp -s /platform/$SRCFI1/s1env/EP/custom/database/install/$FNAM /platform/$SRCFI2/s1env/EP/custom/database/install/$FNAM
  case $? in
    0) echo "$FNAM" >>$TGTFILES.same
      ;;
    1) echo "$FNAM" >>$TGTFILES.diff
      ;;
    *) echo "ERROR: can not access $FNAM"
      ;;
  esac
done

wc -l $TGTFILES.*

cat $TGTFILES.same |cpio -o >/tmp/dbfiles.same.cpio

# must handle diffs
for FNAM in `cat $TGTFILES.diff`
do
  echo $FNAM
  diff /platform/$SRCFI1/s1env/EP/custom/database/install/$FNAM /platform/$SRCFI2/s1env/EP/custom/database/install/$FNAM
done

rm -f $SRCFILES1 $SRCFILES2 $TGTFILES $TGTFILES.same $TGTFILES.diff /tmp/hf$$
