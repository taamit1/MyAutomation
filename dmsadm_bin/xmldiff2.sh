#!/bin/ksh


###################
###  Set the environment for JDK1.2 if you haven't done so
####################
PATH=/usr/java131/bin:$PATH
JAVA_HOME=/usr/java131

################### Set the Compare and Merge Tool directory
export XMLDIFF=/platform/dmsadm/tools/xmldiff


java -DIVB_HOME="$XMLDIFF" -classpath "$XMLDIFF/lib/xmldiff.jar:$XMLDIFF/lib/ivbjfaceall.jar:$XMLDIFF/lib/xml4j.jar:$XMLDIFF/config" com.ibm.ivb.xmldiff.XMLDiffLauncher $1 $2


