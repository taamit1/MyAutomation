<<<<<<< HEAD
// UOB MT - UAT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        WEB = 'multi_preprod_rhel_web'
        APP = 'multi_preprod_aix_app'
        ACT = 'multi_preprod_aix_report'
        FI_NAME = 'fimuob'
        BUILD_TYPE = 'V'
        //BUILD_NAME = 'latest' (set by parametrized choice)
    }
    stages {
        stage('Gather DMS Artifacts') {
            steps {
                echo "Fetching latest IST build artifacts"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
            }
        }
        stage('Prepare Servers') {
            parallel {
                stage ('Actuate') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
                stage ('Web Maint') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage ('UOB Files') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
                stage ('UOB Processes') {
                    stages {
                        stage('UOB Kill NA/DM') {
                            steps {
                                echo "Killing NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                                echo "Killing DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('UOB Start DM/NA') {
                            steps {
                                sleep 10
                                echo "Starting DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                                echo "Starting NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Stage 1') {
            parallel {
                stage('Web') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage('Actuate') {
                    stages {
                        stage('Actuate Update/Start') {
                            steps {
                                echo "Deploying Actuate on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('Reports Deploy') {
                            steps {
                                echo "Deploying Actuate Reports on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Stage 2') {
            stages {
                stage('App Deploy') {
                    steps {
                        echo "Deploying EAR on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                    }
                }
                stage('App Install') {
                    steps {
                        echo "Installing EAR and JAR on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                    }
                }
            }
        }
        stage ('Finish') {
            stages {
                stage('Maint Down') {
                    steps {
                        echo "Removing maintenance page on $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
                stage('Web Restart') {
                    steps {
                        echo "Restarting $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
            }
        }
    }
}
=======
// UOB MT - UAT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        WEB = 'multi_preprod_rhel_web'
        APP = 'multi_preprod_aix_app'
        ACT = 'multi_preprod_aix_report'
        FI_NAME = 'fimuob'
        BUILD_TYPE = 'V'
        //BUILD_NAME = 'latest' (set by parametrized choice)
    }
    stages {
        stage('Gather DMS Artifacts') {
            steps {
                echo "Fetching latest IST build artifacts"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
            }
        }
        stage('Prepare Servers') {
            parallel {
                stage ('Actuate') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
                stage ('Web Maint') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage ('UOB Files') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
                stage ('UOB Processes') {
                    stages {
                        stage('UOB Kill NA/DM') {
                            steps {
                                echo "Killing NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                                echo "Killing DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('UOB Start DM/NA') {
                            steps {
                                sleep 10
                                echo "Starting DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                                echo "Starting NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Stage 1') {
            parallel {
                stage('Web') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage('Actuate') {
                    stages {
                        stage('Actuate Update/Start') {
                            steps {
                                echo "Deploying Actuate on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                        stage('Reports Deploy') {
                            steps {
                                echo "Deploying Actuate Reports on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Stage 2') {
            stages {
                stage('App Deploy') {
                    steps {
                        echo "Deploying EAR on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                    }
                }
                stage('App Install') {
                    steps {
                        echo "Installing EAR and JAR on $APP"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='-PwhZt_CK342e&VB'"
                    }
                }
            }
        }
        stage ('Finish') {
            stages {
                stage('Maint Down') {
                    steps {
                        echo "Removing maintenance page on $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
                stage('Web Restart') {
                    steps {
                        echo "Restarting $WEB"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
            }
        }
    }
}
>>>>>>> 6b01344cade096ba5dd26cfe3d741e0b5c7dfd2b
