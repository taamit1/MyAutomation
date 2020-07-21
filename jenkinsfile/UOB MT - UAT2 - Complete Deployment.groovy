// UOB fimuobu2 - Complete Deployment

pipeline {
    agent {label 'master'}
    environment {
        FI_NAME = "fimuobu2"
        ENVIRONMENT = "uat"
		ANSUSER = "svuatanz"
		ANSKEY = "/usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa"
        DMGR = "'$FI_NAME'_dmgr"
        DB = "'$FI_NAME'_db"
        APP = "'$FI_NAME'_app"
        ACT = "'$FI_NAME'_actuate"
        JCS = "'$FI_NAME'_jcs"
        SCC = "'$FI_NAME'_scc"
		HK = "'$FI_NAME'_hk"
        WEB = "'$FI_NAME'_web"
        ASSEMBLY = "'$FI_NAME'_assembly"
        VARS_FILE = "'$ENVIRONMENT'_'$FI_NAME'.yml"
        INVENTORY = "inventory_'$FI_NAME'"
        UOBVER = '$UOB_VER'
        RELEASENUM = '$RELEASE_NUM'
        TAXPACKAGE = '$TAX_PACKAGE'
		LOGLVL = '-vvvv'

    }
    stages {
        stage('Stage 1 - UOB Assembly') {
            steps {
                echo "Building $BUILD_NAME on $DMS_SERVER"
                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_remote_assembly/uob_remote_assembly.yml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -e target_grp=$ASSEMBLY -e dmgr_grp=$DMGR -e db_grp=$DB -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -u $ANSUSER --private-key=/usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
                echo "Getting Artifacts from $DMS_SERVER"
                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_get_artifacts/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -e '@/usr/local/var/ansible/lfin/uat_dm/environments/uob/uat/group_vars/$FI_NAME/env_specific/vars/main.yml' -e target_grp=$ASSEMBLY -e dmgr_grp=$DMGR -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -e src_finame=$FI_NAME -u $ANSUSER --private-key=/usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
            }
        }
        stage('Stage 2 - Web Maintenance') {
            steps {
                echo "Displaying maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -e operation=up -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=up -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 3 - Misc Deploy') {
            parallel {
                stage('Shared Resources Deploy') {
                    steps {
                        echo "Deploying Shared Resources"
                        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_shared_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -e target_grp=$DMGR -e dmgr_grp=$DMGR -e jcs_grp=$JCS -e scc_grp=$SCC -u svuatanz --private-key=$ANSKEY $LOGLVL"
                    }
                }
                stage('JCS Deploy') {
                    steps {
                        echo "Deploying $JCS"
                        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_jcs/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
                }
                stage('SCC Deploy') {
                    steps {
                        echo "Deploying SCC"
                        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_scc/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e scc_grp=$SCC -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
			    }
                stage('HK Deploy') {
                    steps {
                        echo "Deploying HK"
                        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_hk/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e hk_grp=$HK -e scc_grp=$SCC -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
                }
                //stage('Actuate Deploy') {
                //    steps {
                //        echo "Deploying Actuate"
                //        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e actuate_group='$APP'_clustera -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                //    }
                //}
                stage('Static Content') {
                    steps {
                        echo "Deploying Static Content"
                        sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_static_deploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t deploy_static_contents -e target_grp=$WEB -u $ANSUSER --private-key=/usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
                    }
                }
            }
        }
        stage('Stage 4 -- Deployment') {
            parallel {
                stage ('S4P1') {
                    stages {
                        stage('UOB App Installation') {
                            steps {
                                echo "Installing UOB application on clustera"
                                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_app_install/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY  -e target_grp='$DMGR'_clustera -e app_grp='$APP'_clustera -e db_grp=$DB -u $ANSUSER --private-key /usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
                                echo "Installing UOB application on clusterb"
                                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_app_install/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY  -e target_grp='$DMGR'_clusterb -e app_grp='$APP'_clusterb -e db_grp=$DB -u $ANSUSER --private-key /usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
								}
                            }
                        }
                    }
                }
            }
        stage('Stage 5 - Web Maintenance') {
            steps {
                echo "Displaying maintenance page on $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=down -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_custom_error/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e finame='$FI_NAME' -e operation=down -e code=403 -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                echo "Restarting $WEB"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e vhost='$WEB' -e '@/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_FILE' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        }
        }
