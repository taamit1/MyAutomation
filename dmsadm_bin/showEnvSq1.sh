#
# showEnv.sh
# shows all fi environments and their current version
#
FINAME=`lsuser -a home $LOGNAME | awk -F '/' {'print $3'}`

SHOWALL="N"
SORTVER="N"
while test $# -gt 0
do
  if test "$1" = "-v"
  then
    SORTVER="Y"
  fi
  if test "$1" = "-a"
  then
    SHOWALL="Y"
  fi
  shift
done

if test $FINAME = "fiadm"
then
  SHOWALL="Y"
fi

TMPFIL1=/tmp/se$$
LSTFIL1=/tmp/le$$

>$TMPFIL1

if test "$SHOWALL" = "Y"
then
  ls -d /platform/fi* >$LSTFIL1
else
  ls -d /platform/$FINAME >$LSTFIL1
fi

for NAM in `cat $LSTFIL1`
do
  if test $NAM = "/platform/fiadm"
  then
    continue
  fi
  if test -d $NAM
  then
    EP_VER_FILE="$NAM/.ep_ver"
    if test -s $EP_VER_FILE
    then
      EP_VER_CUR=`awk '{print $2}' $EP_VER_FILE |tail -1`
      EP_AS_DATE=`awk '{print $7 " " $8 " " $11}' $EP_VER_FILE |tail -1`
    else
      EP_VER_CUR="unknown"
      EP_AS_DATE=""
    fi
    FINAME=`basename $NAM |tr '[a-z]' '[A-Z]'`
    echo "$FINAME\t$EP_VER_CUR\t$EP_AS_DATE" >>$TMPFIL1
  fi
done

# handle core releases
if test "$SHOWALL" = "Y"
then
  for NAM in `ls -d /platform/EP* /platform/CB* /platform/CI* /platform/TF* /platform/NA* /platform/UB* 2>>/dev/null`
  do
    if test -d $NAM
    then
      EP_VER_FILE="$NAM/.ep_ver"
      if test -s $EP_VER_FILE
      then
        BNAM=`basename $NAM`
        EP_VER_CUR=`awk '{print substr(d,1,2) $2}' d=$BNAM $EP_VER_FILE |tail -1`
        if test -d $NAM/EP
        then
          EP_AS_DATE=`awk '{print $7 " " $8 " " $11}' $EP_VER_FILE |tail -1`
        else
          EP_AS_DATE="off-line"
        fi
      else
        EP_VER_CUR="unknown"
        EP_AS_DATE=""
      fi
      FINAME="<CORE>"
      echo "$FINAME\t$EP_VER_CUR\t$EP_AS_DATE" >>$TMPFIL1
    fi
  done
fi


echo ""
echo "FINAME\tEP Version    \tSetup Date "
echo "------\t--------------\t-----------"

if test "$SORTVER" = "Y"
then
  sort -t"	" +1 -2 +0 -1 $TMPFIL1 # sort by version than fi####
else
  sort -t"	" +0 -1 +1 -2 $TMPFIL1   # sorted by fi#### than version
fi

rm -f $TMPFIL1 $LSTFIL1
exit 0
