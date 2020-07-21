// UOB MT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        JCS = "muiap01"
        FI_NAME = "${ENVIRONMENT == "ist1" ? "fimuobi1" : "unknown"}"
        VARS_FILE = "testvars.yml"
        //ENVIRONMENT set by parametrized choice
        //BUILD_TYPE set by parametrized choice
        //BUILD_NAME set by parametrized choice
    }
    stages {
        stage('Stage 1 - Prepare') {
            stages {
                stage('JCS Stage') {
                    steps {
                        echo "Staging JCS JAR file on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$JCS' -f 5 -t stage_war -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
                stage('JCS Start') {
                    steps {
                        echo "Starting JCS services on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$JCS' -f 5 -t start_jcs -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
            }
        }
        stage('Stage 2 - Deploy') {
            stages {
                stage('JCS Deploy') {
                    steps {
                        echo "Deploying JCS WAR file on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$JCS' -f 5 -t 'conclude_jcs,deploy_jcs' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
                stage('JCS Restart') {
                    steps {
                        echo "Restarting JCS Service on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -e vhost='$JCS' -f 5 -t 'stop_jcs,start_jcs' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
            }
        }
    }
}
