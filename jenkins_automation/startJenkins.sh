#!/usr/bin/ksh

export JENKINS_HOME=/packages/jenkins
export JAVA_HOME=/usr/java7_64
export JENKINS_BASEDIR=/packages/automation
export JENKINS_OPTS="--prefix=/jenkins --httpPort=9443 --ajp13Port=9444 --sessionTimeout=480"

$JAVA_HOME/jre/bin/java -Dhudson.util.ProcessTree.disable=false -Dcom.ibm.jsse2.disableSSLv3=true -jar $JENKINS_BASEDIR/jenkins.war $JENKINS_OPTS </dev/null >>/support/logs/jenkins/console_log 2>&1 &
