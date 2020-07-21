// IP PROD - Pipeline to get health status of all IP systems

pipeline {
    agent {label 'Ansible'}
    environment {
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/IP_Health_Check/playbook.yaml"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT"
        AGI_ENV = "${ENVIRONMENT == "prod" ? "prod" : "test"}"
        VARS_BASE = "${ENVIRONMENT == "prod" ? "prodvars.yml" : "testvars.yml"}"
        VARS_FILE = "/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_BASE"
        //ACTIVE_SITE set as paramaterized value in Jenkins
    }
    stages {
        stage('Health') {
            parallel {
                stage('MCAS') {
                    stages {
                        stage('Get Javaps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_java -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Javaps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_javapscheck -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Perlps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_perl -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Perlps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_perlpscheck -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_status -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t mcas_check -f 5 -e agi_env=$AGI_ENV -e active_site=$ACTIVE_SITE -e '@$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    stages {
                        stage('Get Javaps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_java -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Javaps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_javapscheck -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Perlps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_perl -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Perlps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_perlpscheck -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_status -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_statuscheck -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Channels') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t icexs_channel -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                    }
                }
                stage('AGI') {
                    stages {
                        stage('Get Dockerps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t agi_dockerps -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Dockerps') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t agi_dockercheck -f 5 -e agi_env=$AGI_ENV -e active_site=$ACTIVE_SITE -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Get Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t agi_status -f 5 -e agi_env=$AGI_ENV -e '@$VARS_FILE' -vv"
                            }
                        }
                        stage('Check Status') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t agi_statuscheck -f 5 -e agi_env=$AGI_ENV -e active_site=$ACTIVE_SITE -e '@$VARS_FILE' -vv"
                            }
                        }
                    }
                }
            }
        }
    }
}
