// UOB MT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        //ENVIRONMENT set by parametrized choice
        WEB = "uob_rhel_web_ihs"
        APP = "${ENVIRONMENT == "ist" ? "muiap01" : "uob_aix_app_was"}"
        ACT = "${ENVIRONMENT == "ist" ? "muiap01" : "uob_aix_app_actuate"}"
        JCS = "${ENVIRONMENT == "ist" ? "muiap01" : "uob_aix_app_jcs"}"
        FI_NAME = "${ENVIRONMENT == "ist" ? "fimuobi1" : "fimuob"}"
        PRIVATE_KEY = "/usr/local/var/ansible/lfin/uat_dm/keys/'$ANSIBLE_USER'.id_rsa"
        //BUILD_TYPE set by parametrized choice
        //BUILD_NAME set by parametrized choice
        //ANSIBLE_USER set by parametrized choice
        //RHEL_USER set by parametrized choice
        //AIX_USER set by parametrized choice
        //AIX_PASS set by parametrized choice
    }
    stages {
        stage('Stage 1 - Shutdown') {
            parallel {
                stage('S1P1 - Actuate') {
                    steps {
                        echo "Stopping Actuate services on $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                    }
                }
                stage('S1P2 - JCS') {
                    steps {
                        echo "Stopping JCS Service on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'stop_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                    }
                }
                stage('S1P3 - WAS') {
                    steps {
                        echo "Killing NA on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                        echo "Killing DM on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                    }
                }
            }
        }
        stage('Stage 2 - Startup') {
            parallel {
                stage('S1P1 - Actuate') {
                    steps {
                        echo "Start Actuate on $ACT"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'start_actuate' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                    }
                }
                stage('S1P2 - JCS') {
                    steps {
                        echo "Starting JCS Service on $JCS"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'start_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                    }
                }
            }
        }
        stage('Stage 3 - Web') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
    }
}
