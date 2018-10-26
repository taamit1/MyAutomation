PURGE_VERS=2
if test $? -eq 0
then
  echo "Cleaning up old ear/jar files in `pwd`:"
  CNT=0
  for NAM in `ls -t DB_SSB_*_fi9999.jar`
  do
    CNT=$(($CNT + 1))
    if test $CNT -gt $PURGE_VERS
    then
      echo "rm $NAM"
    fi
  done
fi
