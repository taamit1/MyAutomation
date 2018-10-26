touch mynewfile

for file in `find .|egrep -v '.svn|~'`
do
 touch -r mynewfile $file
done
