// IP PROD - Pipeline to failover from Limerick to London

pipeline {
    agent {label 'lmuatanssrv01'}
    environment {
        AGI_STATUS_PLAYBOOK = "${CONFIRM == "YES" ? "/apps/infra_ansible/tasks/IP_AGI_Status/playbook.yaml" : "NO"}"
        MCAS_STATUS_PLAYBOOK = "${CONFIRM == "YES" ? "/apps/infra_ansible/tasks/IP_MCAS_Status/playbook.yaml" : "NO"}"
        ICEXS_STATUS_PLAYBOOK = "${CONFIRM == "YES" ? "/apps/infra_ansible/tasks/IP_ICEXS_Status/playbook.yaml" : "NO"}"
        FAILOVER_PLAYBOOK = "${CONFIRM == "YES" ? "/apps/infra_ansible/tasks/IP_STET_Failover/playbookprodLD.yaml" : "NO"}"
        INVENTORY = "/apps/infra_ansible/environments/prod"
        VARS_FILE = "/apps/infra_ansible/vars/prodvars.yml"

    }
    stages {
        stage('Status Before') {
            parallel {
                stage('AGI') {
                    steps {
                        sh "ansible-playbook $AGI_STATUS_PLAYBOOK -i $INVENTORY -t agi_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "ansible-playbook $MCAS_STATUS_PLAYBOOK -i $INVENTORY -t mcas_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('ICE-XS') {
                    steps {
                        sh "ansible-playbook $ICEXS_STATUS_PLAYBOOK -i $INVENTORY -t icexs_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
            }
        }
        stage('Stop Limerick ICE-XS') {
            steps {
                sh "ansible-playbook $FAILOVER_PLAYBOOK -i $INVENTORY -t london_active_icexs_stop -f 5 -e agi_env=prod -e active_site=london"
            }
        }
        stage('Set Limerick Site Status') {
            steps {
                sh "ansible ip_lm_rhel_app_icexs -i $INVENTORY -m shell -a \"echo PASSIVE>/apps/aci/UPF/site_status\" -f 5 --become --become-user=aci"
            }
        }
        stage('Failover') {
            parallel {
                stage('AGI') {
                    steps {
                        sh "ansible-playbook $FAILOVER_PLAYBOOK -i $INVENTORY -t london_active_agi -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "ansible-playbook $FAILOVER_PLAYBOOK -i $INVENTORY -t london_active_mcas -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('DB') {
                    steps {
                        sh "ansible-playbook $FAILOVER_PLAYBOOK -i $INVENTORY -t london_active_sql -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
            }
        }
        stage('Start London ICE-XS') {
            steps {
                sh "ansible-playbook $FAILOVER_PLAYBOOK -i $INVENTORY -t london_active_icexs_start -f 5 -e agi_env=prod -e active_site=london"
            }
        }
        stage('Set London Site Status') {
            steps {
                sh "ansible ip_ld_rhel_app_icexs -i $INVENTORY -m shell -a \"echo ACTIVE>/apps/aci/UPF/site_status\" -f 5 --become --become-user=aci"
            }
        }
        stage('Status After') {
            parallel {
                stage('AGI') {
                    steps {
                        sh "ansible-playbook $AGI_STATUS_PLAYBOOK -i $INVENTORY -t agi_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "ansible-playbook $MCAS_STATUS_PLAYBOOK -i $INVENTORY -t mcas_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
                stage('ICE-XS') {
                    steps {
                        sh "ansible-playbook $ICEXS_STATUS_PLAYBOOK -i $INVENTORY -t icexs_status -f 5 -e agi_env=prod -e active_site=london"
                    }
                }
            }
        }
    }
}
