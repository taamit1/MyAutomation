// IP - Pipeline to restart all services

pipeline {
    agent {label 'master'}
    environment {
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/IP_Full_Platform_Restart/playbook.yaml"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT"
    }
    stages {
        stage('Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t failover_restart_postgres_apsf_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t failover_restart_postgres_mcas_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('NRT') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_postgres_nrt_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
            }
        }
        stage('Application') {
            parallel {
                stage('APSF HAP') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_haproxy_apsf_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('APSF') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_apsf_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('HTTPD') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_httpd_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('MCAS HAP') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_haproxy_mcas_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_mcas_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('MQ') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t restart_mq_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('ICE-XS') {
                    steps {
                        sh "/usr/bin/playbook $PLAYBOOK -i $INVENTORY -t restart_icexs_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
                stage('AGI') {
                    steps {
                        sh "/usr/bin/playbook $PLAYBOOK -i $INVENTORY -t restart_agi_$SITE -f 1 -e '{\"check_redundant_service\": true,\"reboot_linux\": true,\"check_service\": true,\"async_reboot\": false,\"stop_service\": true,\"start_service\": true}'"
                    }
                }
            }
        }
    }
}
