<<<<<<< HEAD
pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
        ANSIBLE_SCRIPT_PATH = '/opt/rh/rh-python36/root/usr/bin'
        ANSIBLE_PATH = '/apps/infra_ansible'
        ENVIRO = '$ENVIRONMENT'
        TARGET_SERVERS = '$SERVERS'
        MYDIR = '$DIR'
    }
    stages {
            stage('Stage 0 RS Connect check') {
                steps {
                    echo "Begin connect test play standalone"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --extra-vars \"first_var=$MYDIR second_var=\" --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 1 - Parallel Testing') {
                parallel {
                    stage ('S1P1') {
                        stages {
                            stage('RS ebtest DVE') {
                                steps {
                                    echo "Begin DVE tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestDVE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S2P2') {
                        stages {
                            stage('RS ebtest PSE') {
                                steps {
                                    echo "Begin PSE tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestPSE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S2P3') {
                        stages {
                            stage('RS ebtest IPID') {
                                steps {
                                    echo "Begin IPID tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestIPID/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }

                }
            }
        }
}
=======
pipeline {
    agent {label 'nxuatanssrv01'}
    environment {
        ANSIBLE_SCRIPT_PATH = '/opt/rh/rh-python36/root/usr/bin'
        ANSIBLE_PATH = '/apps/infra_ansible'
        ENVIRO = '$ENVIRONMENT'
        TARGET_SERVERS = '$SERVERS'
        MYDIR = '$DIR'
    }
    stages {
            stage('Stage 0 RS Connect check') {
                steps {
                    echo "Begin connect test play standalone"
                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSconnect/playbook.yaml --extra-vars \"first_var=$MYDIR second_var=\" --limit $TARGET_SERVERS"
                }
            }
            stage('Stage 1 - Parallel Testing') {
                parallel {
                    stage ('S1P1') {
                        stages {
                            stage('RS ebtest DVE') {
                                steps {
                                    echo "Begin DVE tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestDVE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S2P2') {
                        stages {
                            stage('RS ebtest PSE') {
                                steps {
                                    echo "Begin PSE tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestPSE/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }
                    stage ('S2P3') {
                        stages {
                            stage('RS ebtest IPID') {
                                steps {
                                    echo "Begin IPID tests"
                                    sh "$ANSIBLE_SCRIPT_PATH/ansible-playbook -i $ANSIBLE_PATH/environments/$ENVIRO/ $ANSIBLE_PATH/tasks/ReD-Shield/RSAppEbtestIPID/playbook.yaml --limit $TARGET_SERVERS"
                                }
                            }
                        }
                    }

                }
            }
        }
}
>>>>>>> b5927e74bf6a90ea61f4267320d6676586eb843b
