pipeline {
    agent {label 'lmuatanssrv01'}
    environment {
        ANSIBLE_SCRIPT_PATH = '/opt/rh/rh-python36/root/usr/bin'
        ANSIBLE_PATH = '/apps/infra_ansible'
        ENVIRO = '$ENVIRONMENT'
        DEVICE_GROUP = '$Device_Group'
    }
    stages {
            stage('RS Connect check') {
                steps {
                    echo "Begin connect test play standalone"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/F5/F5Ver/playbook.yaml --extra-vars \"DEVICE_GROUP=$DEVICE_GROUP\""
                }
            }

        }
}
