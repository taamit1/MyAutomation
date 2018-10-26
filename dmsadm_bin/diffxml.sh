#!/bin/ksh
# This script will set up the java classpath with the required libraries
# then call diffxml with the given arguments.
# You may need to edit this file to reflect your own setup.

export DIFFXML_HOME=/platform/dmsadm/tools/diffxml
export DIFFXML_LIB=$DIFFXML_HOME/lib
export DIFFXML_BUILD=$DIFFXML_HOME/build

export CLASSPATH=$DIFFXML_LIB/dom3-xercesImpl.jar:$DIFFXML_LIB/dom3-xml-apis.jar:$DIFFXML_LIB/xpp3-1.1.3.4.C.jar:$DIFFXML_BUILD:$DIFFXML_LIB/diffxml.jar

java org.diffxml.diffxml.DiffXML "$@"
