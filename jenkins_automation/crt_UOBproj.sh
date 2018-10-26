#!/usr/bin/ksh

JAVA_HOME="/usr/java7_64"
FIID=`echo $1 | sed 's/ //g'`
SHORTNAME=`echo $2 | sed 's/ //g'`
DESCRIPTION=$3
SERVERNAME=$4
IP=`echo $5 | sed 's/ //g'`
DMSUSER=`echo $7 | sed 's/ //g'`
APPUser=`echo $6 | sed 's/ //g'`
#ENV=`echo $8 | sed 's/ //g'`

dt=`date +"%d%b%y%H%M%S"`
cwd="/packages/automation"
cnfpth="/packages/jenkins/"
jobpth="/packages/jenkins/jobs"
echo $DESCRIPTION
set -A SRVRNAME `echo "${SERVERNAME}"| sed 's/,/ /g'`
set -A SRVRIP `echo "${IP}"| sed 's/,/ /g'`
set -A APPUSR `echo "${APPUser}"| sed 's/,/ /g'`

if [ ${#SRVRNAME[@]} -eq  ${#SRVRIP[@]} ] && [  ${#SRVRNAME[@]} -eq ${#APPUSR[@]} ]
then

#### Changing Config (config.xml) for new Bank
 cp -p ${cnfpth}/config.xml  ${cnfpth}/config.xml_${dt}

#xml_string="
pstn=`grep -n "</views>" ${cnfpth}/config.xml | awk -F":" '{print $1}'`
pstn1=$((${pstn} - 1))
head -${pstn1} ${cnfpth}/config.xml >> ${cnfpth}/config.xml_tmp

printf << Label >> ${cnfpth}/config.xml_tmp "    <listView>
      <owner class=\"hudson\" reference=\"../../..\"/>
      <name>$SHORTNAME</name>
      <description>$DESCRIPTION</description>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class=\"hudson.model.View\$PropertyList\"/>
      <jobNames class=\"tree-set\">
         <comparator class=\"hudson.util.CaseInsensitiveComparator\"/>
         <string>$SHORTNAME-$FIID-Pass1</string>
         <string>$SHORTNAME-$FIID-Pass2</string>
"
Label

j=0
while [[ $j -lt ${#SRVRNAME[@]} ]]
do
        printf "        <string>$SHORTNAME-$FIID-Pass3-${SRVRNAME[${j}]}</string>\n" >> ${cnfpth}/config.xml_tmp
(( j += 1 ))
done

printf << Label >> ${cnfpth}/config.xml_tmp "      </jobNames>
      <jobFilters/>
      <columns>
          <hudson.views.StatusColumn/>
          <hudson.views.WeatherColumn/>
          <hudson.views.JobColumn/>
          <hudson.views.LastSuccessColumn/>
          <hudson.views.LastFailureColumn/>
          <hudson.views.LastDurationColumn/>
          <hudson.views.BuildButtonColumn/>
       </columns>
    </listView>
"
Label
>> ${cnfpth}/config.xml_tmp

tail +${pstn}  ${cnfpth}/config.xml >> ${cnfpth}/config.xml_tmp
mv ${cnfpth}/config.xml_tmp ${cnfpth}/config.xml
#echo $xml_string

#### Creating Job for new Bank
cp -pr ${cwd}/new_env/Pass1 ${jobpth}/${SHORTNAME}-${FIID}-Pass1
cp -pr ${cwd}/new_env/Pass2 ${jobpth}/${SHORTNAME}-${FIID}-Pass2

perl -p -i -e "s/SHORTNAME/${SHORTNAME}/g" ${jobpth}/${SHORTNAME}-${FIID}-Pass1/config.xml ${jobpth}/${SHORTNAME}-${FIID}-Pass2/config.xml
perl -p -i -e "s/FIID/${FIID}/g" ${jobpth}/${SHORTNAME}-${FIID}-Pass1/config.xml ${jobpth}/${SHORTNAME}-${FIID}-Pass2/config.xml
perl -p -i -e "s/DMSUSER/${DMSUSER}/g" ${jobpth}/${SHORTNAME}-${FIID}-Pass1/config.xml ${jobpth}/${SHORTNAME}-${FIID}-Pass2/config.xml

no_srvr=${#SRVRNAME[@]}
echo $no_srvr
i=0
while [[ $i -lt ${#SRVRNAME[@]} ]]
do
cp -pr ${cwd}/new_env/Pass3 ${jobpth}/${SHORTNAME}-${FIID}-Pass3-${SRVRNAME[${i}]}
perl -p -i -e "s/SHORTNAME/${SHORTNAME}/g"  ${jobpth}/${SHORTNAME}-${FIID}-Pass3-${SRVRNAME[${i}]}/config.xml
perl -p -i -e "s/FIID/${FIID}/g"  ${jobpth}/${SHORTNAME}-${FIID}-Pass3-${SRVRNAME[${i}]}/config.xml
perl -p -i -e "s/APPUSER/${APPUSR[${i}]}/g"  ${jobpth}/${SHORTNAME}-${FIID}-Pass3-${SRVRNAME[${i}]}/config.xml
perl -p -i -e "s/DMGRIP/${SRVRIP[${i}]}/g"  ${jobpth}/${SHORTNAME}-${FIID}-Pass3-${SRVRNAME[${i}]}/config.xml

#i=$(( $i + 1 ))
(( i += 1 ))
done

$JAVA_HOME/jre/bin/java -DJENKINS_HOME=/packages/jenkins -jar jenkins-cli.jar  -s http://192.168.186.51:9443/jenkins/ login --username admin --password p@s5w0rd

$JAVA_HOME/jre/bin/java -DJENKINS_HOME=/packages/jenkins -jar jenkins-cli.jar  -s http://192.168.186.51:9443/jenkins/ reload-configuration --username admin --password p@s5w0rd

else
 echo "Missing one ore more Server Name / Server IP / Application User"
 exit 1
fi
