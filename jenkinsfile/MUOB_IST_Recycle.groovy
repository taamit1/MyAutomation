// UOB fimuobi1 - uob app services restart

pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
		ANSIBLE_CONFIG = "/apps/ansible_pdansible/ansible.cfg"
        FI_NAME = "fimuobi1"
        ENVIRONMENT = "ist"
		ANSUSER = "svuatanz"
		ANSKEY = "/apps/infra_ansible/keys/svc_uat_anz/id_rsa"
        DMGR = "'$FI_NAME'_dmgr"
        DB = "'$FI_NAME'_db"
        APP = "'$FI_NAME'_app"
        MQ = "'$FI_NAME'_mq"
        ACT = "'$FI_NAME'_actuate"
		ACTMASTER = "'$FI_NAME'_actuate_master"
        JCS = "'$FI_NAME'_jcs"
        SCC = "'$FI_NAME'_scc"
		HK = "'FI_NAME'_hk"
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
        stage('Stage 1 - UOB App service restart') {
            steps {
                echo "UOB app services restart"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_services_restart/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e dmgr_grp=$DMGR -e jcs_grp=$JCS -e scc_grp=$SCC -u $ANSUSER --private-key $ANSKEY $LOGLVL"
            }
        }
        stage('Stage 2 - Actuate stop Master') {
            steps {
                echo "Stopping Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACT' --tags 'stop_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 3 - Actuate start Master') {
            steps {
                echo "Starting Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACT' --tags 'start_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
    }
}
