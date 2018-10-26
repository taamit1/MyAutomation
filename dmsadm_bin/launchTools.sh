#
# launchTools.sh
#
ADMUSER="dmsadm"

#java -Xmx1792m -jar ~$ADMUSER/tools/heapanalyzer/ha146.jar &
#java -Xmx1536m -jar ~$ADMUSER/tools/heapanalyzer/ha23.jar &
#java -Xmx1792m -jar ~$ADMUSER/tools/heapanalyzer/ha25.jar &
#java -Xmx1792m -jar ~$ADMUSER/tools/heapanalyzer/ha26.jar &

#java -Xmx1024m -jar ~$ADMUSER/tools/gcanalyzer/ga132.jar &
#java -Xmx1024m -jar ~$ADMUSER/tools/gcanalyzer/ga140.jar &
#java -Xmx1024m -jar ~$ADMUSER/tools/gcanalyzer/ga16.jar &
#java -Xmx1024m -jar ~$ADMUSER/tools/gcanalyzer/ga29.jar &

#java -Xmx512m -jar ~$ADMUSER/tools/jcanalyzer/jca11.jar &
#java -Xmx512m -jar ~$ADMUSER/tools/jcanalyzer/jca14.jar &
#java -Xmx512m -jar ~$ADMUSER/tools/jcanalyzer/jca15.jar &

export PATH=/usr/java5/bin:$PATH   # latest jcanalyzer needs Java5

java -Xmx1792m -jar ~$ADMUSER/tools/heapanalyzer/ha398.jar &

java -Xmx1024m -jar ~$ADMUSER/tools/gcanalyzer/ga396.jar &

cp /platform/$ADMUSER/tools/jcanalyzer/jca.properties.xml .

#java -Xmx512m -jar ~$ADMUSER/tools/jcanalyzer/jca29.jar &
java -Xmx512m -jar ~$ADMUSER/tools/jcanalyzer/jca396.jar &

wait
