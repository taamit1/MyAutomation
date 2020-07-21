// UOB MT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        WEB = "nxi15webuobv001"
        FI_NAME = "${ENVIRONMENT == "ist1" ? "fimuobi1" : "unknown"}"
        VARS_FILE = "testvars.yml"
        //ENVIRONMENT set by parametrized choice
        //BUILD_TYPE set by parametrized choice
        //BUILD_NAME set by parametrized choice
    }
    stages {
        stage('Stage 1 - Deploy') {
            stages {
                stage('Web Stage') {
                    steps {
                        echo "Staging Static Content on $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -t stage -e vhost='$WEB' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
                stage('Web Deploy') {
                    steps {
                        echo "Deploying Static Content to $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -t deploy -e vhost='$WEB' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                    }
                }
            }
        }
        stage('Stage 2 - Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
    }
}
