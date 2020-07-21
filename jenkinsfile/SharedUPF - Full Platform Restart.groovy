// Shared UPF - Pipeline to patch all servers

// Use this for testing
//        EXTRA_ARGS = "-e to_email=first.last@aciworldwide.com -e '{\"reboot_linux\": false,\"stop_service\": false,\"stop_jboss\": false}'"

pipeline {
    agent {label 'lmuatanssrv01'}
    environment {
        PB_NAME = "${REGION == null ? "playbook${ENVIRONMENT}.yaml" : "playbook${ENVIRONMENT}${REGION}.yaml"}"
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/SharedUPF_Full_Platform_Restart/${PB_NAME}"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/${ENVIRONMENT}"
        EXTRA_ARGS = "-e to_email=ray.spiva@aciworldwide.com"
    }
    stages {
        stage('Failover 2 Secondary Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_secondary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_secondary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
        stage('Restart Primary Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_apsf_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb1_err) {
                                echo apsfdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_mcas_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb1_err) {
                                echo mcasdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('Upgrade') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_upgrade_${SITE} ${EXTRA_ARGS}"
                            } catch (upgradedb_err) {
                                echo upgradedb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Failover 2 Primary Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_primary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_primary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
        stage('Restart Secondary Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_apsf_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb2_err) {
                                echo apsfdb2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_mcas_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb2_err) {
                                echo mcasdb2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('NRT') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_postgres_nrt_${SITE} ${EXTRA_ARGS}"
                            } catch (nrtdb_err) {
                                echo nrtdb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Activate Both Databases') {
            parallel {
                stage('APSF') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_both_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_both_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
        stage('Restart HAProxy') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_haproxy_apsf_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfhap1_err) {
                                echo apsfhap1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_haproxy_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcashap1_err) {
                                echo mcashap1_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Restart Applications') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_apsf_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfapp1_err) {
                                echo apsfapp1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasapp1_err) {
                                echo mcasapp1_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Restart Communications') {
            parallel {
                stage('HTTPD') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_httpd_${SITE} ${EXTRA_ARGS}"
                            } catch (httpd1_err) {
                                echo httpd1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t restart_icexs_${SITE} ${EXTRA_ARGS}"
                            } catch (icexs1_err) {
                                echo icexs1_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
    }
}
