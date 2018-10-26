#!/bin/sh

#for i in `find . -name "*_IST_build"`
#do
#    newname=`echo $i | sed 's/\_build/\_TBuild/'`
#    mv $i $newname;
#done

#for i in `find . -name "*-IST-Build"`
#do
#    newname=`echo $i | sed 's/\-Build/\-TBuild/'`
#    mv $i $newname;
#done

for i in `find . -name "TCF37*"`
do
    newname=`echo $i | sed 's/TCF37/TCF/'`
    mv $i $newname
done
