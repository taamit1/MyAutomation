<<<<<<< HEAD
// UOB MT Complete Deployment - IST (with maint page)
pipeline {
    agent any
    environment {
        WEB = 'nxi15webuobv001'
        APP = 'muiap01'
        BUILD_TYPE = 'T'
        FI_NAME = 'fimuobi1'
        BUILD_NAME = 'latest' // using "latest" will grab the latest build from DMS by date/time stamp
                              // to deploy a specifc build use the build number string (e.g. UB6030H0T2)
    }
    stages {
        stage('Gather DMS Artifacts') {
            steps {
                echo "Fetching latest IST build artifacts"
                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
            }
        }
        stage('Prepare Servers') {
            parallel {
                stage ('Web Maint') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage ('Actuate Files') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('UOB Files') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('Actuate Processes') {
                    stages {
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('UOB Processes') {
                    stages {
                        stage('UOB Stopn') {
                            steps {
                                echo "Stopping node agent on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstopn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Stopd') {
                            steps {
                                echo "Stopping deployment manager on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstopd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Startd') {
                            steps {
                                echo "Starting deployment manager on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Startn') {
                            steps {
                                echo "Starting node agent on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Servers') {
            parallel {
                stage('Web') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage('UOB') {
                    stages {
                        stage('App Deploy') {
                            steps {
                                echo "Deploying EAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('App Install') {
                            steps {
                                echo "Installing EAR and JAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage('Actuate') {
                    stages {
                        stage('Actuate Deploy') {
                            steps {
                                echo "Deploying EAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t "deploy_iserver,start_actuate,deploy_reports" -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
            }
        }
        stage ('Finish') {
            stages {
                stage('App Stopjvm') {
                    steps {
                        echo "Stopping cluster on $APP"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstops/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                    }
                }
                stage('Wait 300') {
                    steps {
                        echo "Waiting 300 seconds to ensure application is distributed"
                        sleep 30
                    }
                }
                stage('App Startjvm') {
                    steps {
                        echo "Stopping cluster on $APP"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstarts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                    }
                }
                stage('Maint Down') {
                    steps {
                        echo "Removing maintenance page on $WEB"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
                stage('Web Restart') {
                    steps {
                        echo "Restarting $WEB"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
            }
        }
    }
}
=======
// UOB MT Complete Deployment - IST (with maint page)
pipeline {
    agent any
    environment {
        WEB = 'nxi15webuobv001'
        APP = 'muiap01'
        BUILD_TYPE = 'T'
        FI_NAME = 'fimuobi1'
        BUILD_NAME = 'latest' // using "latest" will grab the latest build from DMS by date/time stamp
                              // to deploy a specifc build use the build number string (e.g. UB6030H0T2)
    }
    stages {
        stage('Gather DMS Artifacts') {
            steps {
                echo "Fetching latest IST build artifacts"
                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/uob_gather_dms_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e fi_name='$FI_NAME' -e build_type='$BUILD_TYPE' -e build_number_input='$BUILD_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
            }
        }
        stage('Prepare Servers') {
            parallel {
                stage ('Web Maint') {
                    stages {
                        stage('Maint Up') {
                            steps {
                                echo "Displaying maintenance page on $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t up -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=up -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Restart') {
                            steps {
                                echo "Restarting $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage ('Actuate Files') {
                    stages {
                        stage('Actuate Copy') {
                            steps {
                                echo "Copying Actuate JAR file to $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t stage_jar -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('UOB Files') {
                    stages {
                        stage('UOB Copy') {
                            steps {
                                echo "Copying EAR and JAR files to $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/uob_push_ear-jar/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Link') {
                            steps {
                                echo "Linking EAR and JAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_preplinks/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('Actuate Processes') {
                    stages {
                        stage('Actuate Stop') {
                            steps {
                                echo "Stopping Actuate services on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t stop_actuate -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage ('UOB Processes') {
                    stages {
                        stage('UOB Stopn') {
                            steps {
                                echo "Stopping node agent on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstopn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Stopd') {
                            steps {
                                echo "Stopping deployment manager on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstopd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Startd') {
                            steps {
                                echo "Starting deployment manager on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartd/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('UOB Startn') {
                            steps {
                                echo "Starting node agent on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstartn/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
            }
        }
        stage('Update Servers') {
            parallel {
                stage('Web') {
                    stages {
                        stage('Web Stage') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t stage -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                        stage('Web Deploy') {
                            steps {
                                echo "Deploying Static Content to $WEB"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_update_static_content/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -t deploy -e vhost='$WEB' -e fi_list='$FI_NAME' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                            }
                        }
                    }
                }
                stage('UOB') {
                    stages {
                        stage('App Deploy') {
                            steps {
                                echo "Deploying EAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                        stage('App Install') {
                            steps {
                                echo "Installing EAR and JAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_appinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
                stage('Actuate') {
                    stages {
                        stage('Actuate Deploy') {
                            steps {
                                echo "Deploying EAR on $APP"
                                //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook_acdeploy.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -e vhost='$APP' -f 5 -t "deploy_iserver,start_actuate,deploy_reports" -e finame='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                            }
                        }
                    }
                }
            }
        }
        stage ('Finish') {
            stages {
                stage('App Stopjvm') {
                    steps {
                        echo "Stopping cluster on $APP"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstops/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                    }
                }
                stage('Wait 300') {
                    steps {
                        echo "Waiting 300 seconds to ensure application is distributed"
                        sleep 30
                    }
                }
                stage('App Startjvm') {
                    steps {
                        echo "Stopping cluster on $APP"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/arlm_preprod/arlm_jvmstarts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e variable_host='$APP' -e fi_name='$FI_NAME' -e ansible_ssh_user=rspiva -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa -e ansible_sudo_pass='!m8cG2znpwq=8AUj'"
                    }
                }
                stage('Maint Down') {
                    steps {
                        echo "Removing maintenance page on $WEB"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t down -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e fi_list='$FI_NAME' -e operation=down -e code=403 -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
                stage('Web Restart') {
                    steps {
                        echo "Restarting $WEB"
                        //sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -f 5 -e vhost='$WEB' -e ansible_ssh_user=spivar -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/rspiva.id_rsa"
                    }
                }
            }
        }
    }
}
>>>>>>> 6b01344cade096ba5dd26cfe3d741e0b5c7dfd2b
