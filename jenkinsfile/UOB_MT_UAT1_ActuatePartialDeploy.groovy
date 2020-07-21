 // UOB fimuobu1 - Complete Deployment

pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
	ANSIBLE_CONFIG = "/apps/ansible_pdansible/ansible.cfg"
        FI_NAME = "fimuob"
        ENVIRONMENT = "uat"
		ANSUSER = "svuatanz"
		ANSKEY = "/apps/infra_ansible/keys/svc_uat_anz/id_rsa"
        DMGR = "'$FI_NAME'_dmgr"
        DB = "'$FI_NAME'_db"
        APP = "'$FI_NAME'_app"
        ACT = "'$FI_NAME'_actuate"
        JCS = "'$FI_NAME'_jcs"
        SCC = "'$FI_NAME'_scc"
        WEB = "'$FI_NAME'_web"
        ASSEMBLY = "'$FI_NAME'_assembly"
        //VARS_FILE = "'$ENVIRONMENT'_'$FI_NAME'.yml"
        INVENTORY = "inventory_'$FI_NAME'"
        UOBVER = '$UOB_VER'
        //RELEASENUM = '$RELEASE_NUM'
        //TAXPACKAGE = '$TAX_PACKAGE'
		LOGLVL = '-vvvv'


    }
    stages {
        stage('Stage 1 - UOB Assembly') {
            steps {
			    script {
                if ("${ASSEMBLE}" == 'true') {
                echo "Building $BUILD_NAME on $DMS_SERVER"
                sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_remote_assembly/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e '@/apps/infra_ansible/environments/uob/$ENVIRONMENT/group_vars/$FI_NAME/env_specific/vars/main.yml' -e target_grp=$ASSEMBLY -e dmgr_grp=$DMGR -e db_grp=$DB -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -e custom_release=$CUST_RELEASENUM -u $ANSUSER --private-key=/apps/infra_ansible/keys/svc_uat_anz/id_rsa $LOGLVL" }
				else { echo 'Skipping Build on $DMS_SERVER' }
				}
                echo "Getting Artifacts from $DMS_SERVER"
                sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_get_artifacts/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e '@/apps/infra_ansible/environments/uob/$ENVIRONMENT/group_vars/$FI_NAME/env_specific/vars/main.yml' -e target_grp=$ASSEMBLY -e dmgr_grp=$DMGR -e core_release=UOB_$RELEASENUM -e tax_release=$TAXPACKAGE -e src_finame=$FI_NAME -e custom_release=$CUST_RELEASENUM -t uob_release,scc_release,cfg_repo -u $ANSUSER --private-key=/apps/infra_ansible/keys/svc_uat_anz/id_rsa $LOGLVL"
            }
        }
        stage('Stage 2 - Partial Actuate Deploy') {
                steps {
                        echo "Stopping Actuate"
                        sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t stop_actuate -e actuate_group='$ACT' -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
						echo "Deploying Iserver"
                        sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t deploy_iserver -e actuate_group='$ACT' -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
						echo "Enable RSSE"
                        sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t enable_rsse -e actuate_group='$ACT' -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
						echo "Start Actuate"
                        sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t start_actuate -e actuate_group='$ACT' -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
						echo "Deploy Reports"
                        sh "/usr/bin/ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -f 5 -t deploy_reports -e actuate_group='$ACT'_master -e db_grp='$DB' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
                    }
            }
    }
}
