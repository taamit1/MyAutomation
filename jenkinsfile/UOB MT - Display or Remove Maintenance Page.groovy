<<<<<<< HEAD
// UOB MT - Display or Remove Maintenance Page

pipeline {
    agent {label 'master'}
    environment {
        //ENVIRONMENT set by parametrized choice
        WEB = "uob_rhel_web_ihs"
        //TASK set by parametrized choice
        FI_NAME = "${ENVIRONMENT == "ist" ? "fimuobi1" : "fimuob"}"

    }
    stages {
        stage('Maint Up') {
            steps {
                echo "Displaying maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=up -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=up -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
    }
}
=======
// UOB MT - Display or Remove Maintenance Page

pipeline {
    agent {label 'master'}
    environment {
        //ENVIRONMENT set by parametrized choice
        WEB = "uob_rhel_web_ihs"
        //TASK set by parametrized choice
        FI_NAME = "${ENVIRONMENT == "ist" ? "fimuobi1" : "fimuob"}"

    }
    stages {
        stage('Maint Up') {
            steps {
                echo "Displaying maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=up -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=up -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
    }
}
>>>>>>> 6b01344cade096ba5dd26cfe3d741e0b5c7dfd2b
