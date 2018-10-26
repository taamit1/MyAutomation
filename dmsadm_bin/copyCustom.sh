#
# copyCustom.sh
#
export PATH=$PATH:/usr/java131/bin

TMP1=/tmp/cC$$

PWD=`pwd`
CDIR=`echo $PWD|sed -e "s?^.*Banking?$HOME/s1env/EP/Banking?"`
TDIR=`echo $PWD|sed -e "s?^.*Banking?$HOME/s1env/EP/custom?"`

echo "Source Directory = $PWD"
echo "Core   Directory = $CDIR"
echo "Target Directory = $TDIR"

if test "$PWD" = "$TDIR"
then
  echo "Cannot run from the target directory."
  exit 1
fi

echo "Ok to copy changed files from source to target? \c"
read ans
if test "$ans" = "y" -o "$ans" = "Y"
then
  echo "Starting..."
else
  echo "Exiting..."
  exit 0
fi


find . -type f >$TMP1
while true
do
  read NAM
  if test "$NAM" = ""
  then
    break
  fi
  NAM=`echo $NAM|sed -e "s/^\.\///"`

  SNAM="$PWD/$NAM"
  CNAM="$CDIR/$NAM"
  TNAM="$TDIR/$NAM"

  cmp -s "$SNAM" "$CNAM" >>/dev/null 2>&1
  case $? in
  1) echo "CHG $SNAM -> $TNAM"
    ;;
  2) echo "NEW $SNAM -> $TNAM"
    ;;
  *)continue
    ;;
  esac

  NDIR=`dirname $TNAM`
  if test ! -d $NDIR
  then
    mkdir -p $NDIR
  fi
  cp -p $SNAM $TNAM

done<$TMP1

rm -f $TMP1
exit 0
