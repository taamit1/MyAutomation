pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
        ANSIBLE_SCRIPT_PATH = '/opt/rh/rh-python36/root/usr/bin'
        ANSIBLE_PATH = '/apps/infra_ansible'
        ENVIRO = '$ENVIRONMENT'
        TARGET_SERVERS = '$SERVERS'
    }
    stages {
            stage('RS Connect check') {
                steps {
                    echo "Begin connect test play standalone"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --limit $TARGET_SERVERS"
                }
            }

        }
}
