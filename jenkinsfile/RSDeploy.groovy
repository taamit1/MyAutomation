pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
        ANSIBLE_SCRIPT_PATH = '/opt/rh/rh-python36/root/usr/bin'
        ANSIBLE_PATH = '/apps/infra_ansible'
        ENVIRO = '$ENVIRONMENT'
        SHUTDOWN_LEVEL = '$SHUTDOWN_LEVEL'
        TARGET_SERVERS = '$SERVERS'
        THIS_ATTEMPT = '$INSTALL_ATTEMPT'
        THIS_VERSION = '$VERSION_DETAIL'
        THIS_CR = '$CR_NUMBER'
    }
    stages {
            stage('Stage 0 RS Connectivity and Sudo check') {
                steps {
                    echo "Begin connect test"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 1 F5 Node change') {
                steps {
                    echo "Remove server from customer traffic"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 2 RS app stop') {
                steps {
                    echo "Begin App shutdown"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RS_$SHUTDOWN_LEVEL_Stop/playbook.yaml --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 3 Deploy core code') {
                steps {
                    echo "Begin file deployment"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSdeploy/playbook.yaml --extra-vars \"THIS_ATTEMPT=$THIS_ATTEMPT, THIS_VERSION=$THIS_VERSION, THIS_CR=$THIS_CR\" --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 4 RS app start') {
                steps {
                    echo "Begin App startup"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RS_$SHUTDOWN_LEVEL_Start/playbook.yaml --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 5 - Parallel tests') {
                parallel {
                    stage ('S5P1') {
                        stages {
                            stage('RS ebtest DVE') {
                                steps {
                                    echo "Begin DVE test"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestDVE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S5P2') {
                        stages {
                            stage('RS ebtest PSE') {
                                steps {
                                    echo "Begin PSE test"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestIPID/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S5P3') {
                        stages {
                            stage('RS ebtest IPID') {
                                steps {
                                    echo "Begin IPID test"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestPSE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S5P4') {
                        stages {
                            stage('RS ebtest validation') {
                                steps {
                                    echo "Begin release specific test"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestDVE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }

                }
            }
            stage('Stage 6 RS Post deploy Validation') {
                steps {
                    echo "Begin validation tests"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --limit $TARGET_SERVERS"
                }
            }
        }
}
