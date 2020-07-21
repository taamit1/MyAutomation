// IP PROD - Pipeline to harden environment with application configurations

pipeline {
    agent {label 'master'}
    environment {
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/SharedUPF_Hardening/playbook.yaml"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT"
        VARS_BASE = "${ENVIRONMENT == "prod" ? "prodvars.yml" : "testvars.yml"}"
        VARS_FILE = "/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_BASE"
        TAG_PREFIX = "${ACTION == "apply" ? "disable" : "show"}"
    }
    stages {
        stage('Hardening') {
            parallel {
                stage('MCAS') {
                    stages {
                        stage('Ciphers') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_mcas_ciphers -f 5 -e '@$VARS_FILE'"
                            }
                        }
                        stage('JMX') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_mcas_jmx -f 5 -e '@$VARS_FILE'"
                            }
                        }
                    }
                }
                stage('APSF') {
                    stages {
                        stage('Ciphers') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_apsf_ciphers -f 5 -e '@$VARS_FILE'"
                            }
                        }
                    }
                }
                stage('DB') {
                    stages {
                        stage('RT Ciphers') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_postgresrt_ciphers -f 5 -e '@$VARS_FILE'"
                            }
                        }
                        stage('NRT Ciphers') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_postgresnrt_ciphers -f 5 -e '@$VARS_FILE'"
                            }
                        }
                    }
                }
                stage('OS') {
                    stages {
                        stage('SSHD Config') {
                            steps {
                            sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t ${TAG_PREFIX}_root_sshd_config -f 5 -e '@$VARS_FILE'"
                            }
                        }
                    }
                }
            }
        }
    }
}
