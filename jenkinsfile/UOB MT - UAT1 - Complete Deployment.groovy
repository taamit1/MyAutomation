// UOB MT - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        //ENVIRONMENT set by parametrized choice
        WEB = "uob_rhel_web_ihs"
        APP = "uob_aix_app_was"
        ACT = "uob_aix_app_actuate"
        JCS = "uob_aix_app_jcs"
        FI_NAME = "fimuob"
        VARS_FILE = "testvars.yml"
        //BUILD_TYPE set by parametrized choice
        //BUILD_NAME set by parametrized choice
    }
    stages {
        stage('Stage 1 - DMS Pull') {
            steps {
                echo "Fetching latest $ENVIRONMENT build artifacts"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e finame='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Stage 2 - Prepare') {
            parallel {
                stage ('S2P1') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stage_jar -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t stop_actuate -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage ('S2P2') {
                    stages {
                        stage('JCS Stage') {
                            steps {
                                echo "Staging JCS JAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t stage_war -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('JCS Start') {
                            steps {
                                echo "Starting JCS services on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t start_jcs -e finame='$FI_NAME'  -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage ('S2P3') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$APP' -f 5 -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage ('S2P4') {
                    stages {
                        stage('UOB Kill NA/DM') {
                            steps {
                                echo "Killing NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_jvmkilln/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                                echo "Killing DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_jvmkilld/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('UOB Start DM/NA') {
                            steps {
                                sleep 10
                                echo "Starting DM on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                                echo "Starting NA on $APP"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage ('S2P5') {
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
            }
        }
        stage('Stage 3 - Misc Deploy') {
            parallel {
                stage('S3P1') {
                    stages {
                        stage('Actuate Update/Start') {
                            steps {
                                echo "Deploying Actuate on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_iserver,start_actuate' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('Reports Deploy') {
                            steps {
                                echo "Deploying Actuate Reports on $ACT"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$ACT' -f 5 -t 'deploy_reports' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage('S3P2') {
                    stages {
                        stage('JCS Deploy') {
                            steps {
                                echo "Deploying JCS WAR file on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'conclude_jcs,deploy_jcs' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('JCS Restart') {
                            steps {
                                echo "Restarting JCS Service on $JCS"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_jcs_aod/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -e vhost='$JCS' -f 5 -t 'stop_jcs,start_jcs' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage('S3P3') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t stage -e vhost='$WEB' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -t deploy -e vhost='$WEB' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                            }
                        }
                    }
                }
            }
        }
        stage('Stage 4 - UOB Deploy') {
            steps {
                echo "Deploying EAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Stage 5 - UOB Install') {
            steps {
                echo "Installing EAR and JAR on $APP"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$APP' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Stage 6 - Maint Down') {
            steps {
                echo "Removing maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=down -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=down -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
        stage('Stage 7 - Web Restart') {
            steps {
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -vv"
            }
        }
    }
}
