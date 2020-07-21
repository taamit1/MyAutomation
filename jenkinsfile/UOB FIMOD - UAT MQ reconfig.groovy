// UOB fimod - MQ reconfig

pipeline {
    agent {label 'master'}
    environment {
        FI_NAME = "fimod"
        ENVIRONMENT = "uat"
		ANSUSER = "svuatanz"
        DMGR = "'$FI_NAME'_dmgr"
        DB = "'$FI_NAME'_db"
        APP = "'$FI_NAME'_app"
        MQ = "'$FI_NAME'_mq"
        ACT = "'$FI_NAME'_actuate"
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
        stage('Stage 1 - MQ reconfig on cluster1') {
            steps {
                echo "Reconfiguring MQ on '$APP'_cluster1"
                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_was_mqreconfig/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY  -e target_grp='$DMGR'_cluster1 -e dmgr_grp='$DMGR'_cluster1 -e app_grp='$APP'_cluster1 -e @/usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/group_vars/$FI_NAME/env_specific/vars/cluster1.yml -u $ANSUSER --private-key /usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
            }
        }
        stage('Stage 2 - MQ reconfig on cluster2') {
            steps {
                echo "Reconfiguring MQ on '$APP'_cluster2"
                sh "/usr/bin/ansible-playbook /home/rgardner/pdansible/$UOBVER/tasks/uob_was_mqreconfig/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/$INVENTORY  -e target_grp='$DMGR'_cluster2 -e dmgr_grp='$DMGR'_cluster2 -e app_grp='$APP'_cluster2 -e @/usr/local/var/ansible/lfin/uat_dm/environments/uob/$ENVIRONMENT/group_vars/$FI_NAME/env_specific/vars/cluster2.yml -u $ANSUSER --private-key /usr/local/var/ansible/lfin/uat_dm/keys/svc_uat_anz/id_rsa $LOGLVL"
            }
        }
    }
}
