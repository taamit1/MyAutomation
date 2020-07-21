// UOB MT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        ACT = "muiap01"
        FI_NAME = "${ENVIRONMENT == "ist1" ? "fimuobi1" : "unknown"}"
        VARS_FILE = "testvars.yml"
        //ENVIRONMENT set by parametrized choice
        //BUILD_TYPE set by parametrized choice
        //BUILD_NAME set by parametrized choice
    }
    stages {
        stage('Stage 1 - Prepare') {
            stages {
                stage('Actuate Copy') {
                    steps {
                        echo "Copying Actuate JAR file to $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
                stage('Actuate Stop') {
                    steps {
                        echo "Stopping Actuate services on $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
            }
        }
        stage('Stage 2 - Deploy') {
            stages {
                stage('Actuate Update/Start') {
                    steps {
                        echo "Deploying Actuate on $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
                stage('Reports Deploy') {
                    steps {
                        echo "Deploying Actuate Reports on $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
            }
        }
    }
}
