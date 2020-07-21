// UOB fimod - Complete Deployment

pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
	ANSIBLE_CONFIG = "/apps/ansible_pdansible/ansible.cfg"
        FI_NAME = "fimod"
        ENVIRONMENT = "uat"
        ANSUSER = "svuatanz"
        ANSKEY = "/apps/infra_ansible/keys/svc_uat_anz/id_rsa"
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
                script {
                if ("${ASSEMBLE}" == 'true') {
                echo "Building $BUILD_NAME on $DMS_SERVER"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_remote_assembly/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e target_grp=$ASSEMBLY -e dmgr_grp=$DMGR -e db_grp=$DB -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -u svuatanz --private-key=$ANSKEY $LOGLVL" }
                else { echo 'Skipping Build on $DMS_SERVER' }
                }
                echo "Getting Artifacts from $DMS_SERVER"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_get_artifacts/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY --skip-tags dp_release -e '@/apps/infra_ansible/environments/uob/uat/group_vars/$FI_NAME/env_specific/vars/main.yml' -e target_grp=$ASSEMBLY -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -e src_finame=$FI_NAME -u svuatanz --private-key=$ANSKEY -e dmgr_grp=$DMGR $LOGLVL"
            }
        }
        stage('Stage 2 - JCS Deploy') {
            steps {
                echo "Deploying $JCS"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_jcs/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 3 - Misc Deploy') {
            parallel {
                stage('Config-Repo Deploy') {
                    steps {
                        echo "Deploying Config-Repo"
                        sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_config_repo/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -t cfg_repo_deploy -e target_grp=$SCC -e dmgr_grp=$DMGR -e jcs_grp=$JCS -e scc_grp=$SCC -u svuatanz --private-key $ANSKEY $LOGLVL"
                    }
                }
                stage('Shared Resources Deploy') {
                    steps {
                        echo "Deploying Shared Resources"
                        sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_shared_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e target_grp=$DMGR -e dmgr_grp=$DMGR -e jcs_grp=$JCS -e scc_grp=$SCC -u svuatanz --private-key $ANSKEY $LOGLVL"
                    }
                }
                stage('SCC Deploy') {
                    steps {
                        echo "Deploying SCC"
                        sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_scc/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e scc_grp=$SCC -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
                }
                stage('Actuate Deploy') {
                    steps {
                        echo "Deploying Actuate"
                        sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e actuate_group=fimod_app_cluster1 -e db_grp=fimod_db -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
                }
                stage('Static Content') {
                    steps {
                        echo "Deploying Static Content"
                        sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_static_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t deploy_static_contents -e target_grp=$WEB -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
                }
            }
        }
        stage('Stage 4 - HK deploy') {
            steps {
                script {
                if ("${DEPLOY_HONGKONG}" == 'true') {
                echo "Deploying HK CHATS Micro Services"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_hk/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -e hk_grp=$HK -e scc_grp=$SCC -e jcs_grp=$JCS -u $ANSUSER --private-key=$ANSKEY $LOGLVL" }
                else { echo 'Skipping HK CHATS Mico service deployment' }
                }
            }
        }
        stage('Stage 5 - UOB App Deploy') {
            steps {
                echo "Installing UOB application on cluster1"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_app_install/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e dmgr_grp='$DMGR'  -e target_grp='$DMGR'_cluster1 -e app_grp='$APP'_cluster1 -e db_grp=$DB -e jcs_grp='$JCS' -e scc_grp='$SCC' -u $ANSUSER --private-key $ANSKEY $LOGLVL"
                echo "Installing UOB application on cluster2"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_app_install/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e dmgr_grp='$DMGR'  -e target_grp='$DMGR'_cluster2 -e app_grp='$APP'_cluster2 -e db_grp=$DB -e jcs_grp='$JCS' -e scc_grp='$SCC' -u $ANSUSER --private-key $ANSKEY $LOGLVL"
                 }
            }
        }
    }
