// UOB fimuobu1 - actuate restart

pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
        FI_NAME = "fimuob"
        ENVIRONMENT = "uat"
		ANSUSER = "svuatanz"
		ANSKEY = "/apps/infra_ansible/keys/svc_uat_anz/id_rsa"
        ACTMASTER = "'$FI_NAME'_actuate_master"
        ACTSLAVE = "'$FI_NAME'_actuate_slave"
        ASSEMBLY = "'$FI_NAME'_assembly"
        INVENTORY = "inventory_'$FI_NAME'"
        UOBVER = '6.0.15'
		LOGLVL = '-vvvv'
		ANSIBLE_CONFIG="/apps/ansible_pdansible/ansible.cfg"
    }
    stages {
        stage('Stage 1 - Actuate stop master') {
            steps {
                echo "Stopping Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACTMASTER' --tags 'stop_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 2 - Actuate start master') {
            steps {
                echo "Starting Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACTMASTER' --tags 'start_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 3 - Actuate stop slave') {
            steps {
                echo "Stopping Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACTSLAVE' --tags 'stop_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
        stage('Stage 4 - Actuate start slave') {
            steps {
                echo "Starting Actuate"
                sh "ansible-playbook /apps/ansible_pdansible/$UOBVER/tasks/uob_actuate_deploy/playbook.yaml -i /apps/infra_ansible/environments/uob/$ENVIRONMENT/$INVENTORY -e actuate_group='$ACTSLAVE' --tags 'start_actuate' -u $ANSUSER --private-key=$ANSKEY $LOGLVL"
            }
        }
    }
}
