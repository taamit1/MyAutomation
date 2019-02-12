svnpath=.
echo "Changing the timestamp for all files under custom to current timestamp for resolving a bug in EnvMgr..."

#export LDR_CNTRL=MAXDATA=0x8000000

touch mynewfile

find ${svnpath}|egrep -v '.svn|~'|while read FILE
do
 touch -r mynewfile "$FILE"
done

#find . |egrep -v '.svn|~'| xargs touch -r

echo
echo "Done"
