<<<<<<< HEAD
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
        stage('Stage 1 - DMS Pull') {
            steps {
                echo "Fetching latest $ENVIRONMENT build artifacts"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
        stage('Stage 2 - Prepare') {
            parallel {
                stage ('S2P1') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P2') {
                    stages {
                        stage('JCS Stage') {
                            steps {
                                echo "Staging JCS JAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t stage_war -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('JCS Start') {
                            steps {
                                echo "Starting JCS services on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t start_jcs -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P3') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P4') {
                    stages {
                        stage('UOB Kill NA/DM') {
                            steps {
                                echo "Killing NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                                echo "Killing DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('UOB Start DM/NA') {
                            steps {
                                sleep 10
                                echo "Starting DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                                echo "Starting NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P5') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                    }
                }
            }
        }
        stage('Stage 3 - Misc Deploy') {
            parallel {
                stage('S3P1') {
                    stages {
                        stage('Actuate Update/Start') {
                            steps {
                                echo "Deploying Actuate on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('Reports Deploy') {
                            steps {
                                echo "Deploying Actuate Reports on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage('S3P2') {
                    stages {
                        stage('JCS Deploy') {
                            steps {
                                echo "Deploying JCS WAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'conclude_jcs,deploy_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('JCS Restart') {
                            steps {
                                echo "Restarting JCS Service on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'stop_jcs,start_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage('S3P3') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                    }
                }
            }
        }
        stage('Stage 4 - UOB Deploy') {
            steps {
                echo "Deploying EAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
            }
        }
        stage('Stage 5 - UOB Install') {
            steps {
                echo "Installing EAR and JAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
            }
        }
        stage('Stage 6 - Maint Down') {
            steps {
                echo "Removing maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
        stage('Stage 7 - Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
    }
}
=======
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
        stage('Stage 1 - DMS Pull') {
            steps {
                echo "Fetching latest $ENVIRONMENT build artifacts"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
        stage('Stage 2 - Prepare') {
            parallel {
                stage ('S2P1') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P2') {
                    stages {
                        stage('JCS Stage') {
                            steps {
                                echo "Staging JCS JAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t stage_war -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('JCS Start') {
                            steps {
                                echo "Starting JCS services on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t start_jcs -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P3') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P4') {
                    stages {
                        stage('UOB Kill NA/DM') {
                            steps {
                                echo "Killing NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                                echo "Killing DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('UOB Start DM/NA') {
                            steps {
                                sleep 10
                                echo "Starting DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                                echo "Starting NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage ('S2P5') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                    }
                }
            }
        }
        stage('Stage 3 - Misc Deploy') {
            parallel {
                stage('S3P1') {
                    stages {
                        stage('Actuate Update/Start') {
                            steps {
                                echo "Deploying Actuate on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('Reports Deploy') {
                            steps {
                                echo "Deploying Actuate Reports on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage('S3P2') {
                    stages {
                        stage('JCS Deploy') {
                            steps {
                                echo "Deploying JCS WAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'conclude_jcs,deploy_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                        stage('JCS Restart') {
                            steps {
                                echo "Restarting JCS Service on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'stop_jcs,start_jcs' -e finame='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
                            }
                        }
                    }
                }
                stage('S3P3') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                            }
                        }
                    }
                }
            }
        }
        stage('Stage 4 - UOB Deploy') {
            steps {
                echo "Deploying EAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
            }
        }
        stage('Stage 5 - UOB Install') {
            steps {
                echo "Installing EAR and JAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user='$AIX_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -e ansible_sudo_pass='$AIX_PASS' -vv"
            }
        }
        stage('Stage 6 - Maint Down') {
            steps {
                echo "Removing maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
        stage('Stage 7 - Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e ansible_ssh_user='$RHEL_USER' -e ansible_ssh_private_key_file='$PRIVATE_KEY' -vv"
            }
        }
    }
}
>>>>>>> 6b01344cade096ba5dd26cfe3d741e0b5c7dfd2b
