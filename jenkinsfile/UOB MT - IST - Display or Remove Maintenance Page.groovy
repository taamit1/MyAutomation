// UOB MT - Display or Remove Maintenance Page

pipeline {
    agent {label 'master'}
    environment {
        WEB = "nxi15webuobv001"
        FI_NAME = "${ENVIRONMENT == "ist1" ? "fimuobi1" : "unknown"}"
        VARS_FILE = "testvars.yml"
        //ENVIRONMENT set by parametrized choice
        //TASK set by parametrized choice
    }
    stages {
        stage('Maintenance') {
            steps {
                echo "Displaying maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=$TASK -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=$TASK -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/ist -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
    }
}
