for f in `grep "charanjeet" /packages/automation/*.ksh|awk -F":" '{print $1}'`
do
 echo "Taking backup of $f"
 #cp -p $f $f.bak
 echo "Removing string and moving to new file"
 #grep -v "charanjeet" $f > temp && mv temp $f && chmod +x $f
 echo "Move done"
 sleep 2
done
