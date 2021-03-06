// Shared UPF - Pipeline to patch all servers

// Use this for testing
//        EXTRA_ARGS = "-e server_shutdown_uptime=2000000 -e to_email=first.last@aciworldwide.com -e '{\"stop_service\": false,\"stop_jboss\": false}'"

pipeline {
    agent {label 'lmuatanssrv01'}
    environment {
        PB_NAME = "playbook${ENVIRONMENT}.yaml"
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/SharedUPF_Platform_Patching/${PB_NAME}"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/${ENVIRONMENT}"
        EXTRA_ARGS = "-e to_email=ray.spiva@aciworldwide.com"
    }
    stages {
        stage('Failover 2 Secondary?') {
            steps {
                input message:'Failover 2 Secondary?'
            }
        }
        stage('Failover 2 Secondary') {
            parallel {
                stage('APSF DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_secondary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_secondary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
        stage('Patch Primary?') {
            steps {
                input message:'Patch Primary?'
            }
        }
        stage('Patch Primary') {
            parallel {
                stage('APSF DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_apsf_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb1_err) {
                                echo apsfdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('APSF HAP') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_apsf_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfhap1_err) {
                                echo apsfhap1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_apsf_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfapp1_err) {
                                echo apsfapp1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('HTTPD') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_httpd_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (httpd1_err) {
                                echo httpd1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_mcas_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb1_err) {
                                echo mcasdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS HAP') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_mcas_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcashap1_err) {
                                echo mcashap1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_mcas_primary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasapp1_err) {
                                echo mcasapp1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_icexs_primary_${SITE} ${EXTRA_ARGS} -e '{\"active_site\": true}'"
                            } catch (icexs1_err) {
                                echo icexs1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('Upgrade DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_upgrade_${SITE} ${EXTRA_ARGS} -e '{\"start_service\": false}'"
                            } catch (upgradedb_err) {
                                echo upgradedb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Failover 2 Primary?') {
            steps {
                input message:'Failover 2 Primary?'
            }
        }
        stage('Failover 2 Primary') {
            parallel {
                stage('APSF DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_primary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_primary_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
        stage('Patch Secondary?') {
            steps {
                input message:'Patch Secondary?'
            }
        }
        stage('Patch Secondary') {
            parallel {
                stage('APSF DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_apsf_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb2_err) {
                                echo apsfdb2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('APSF HAP') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_apsf_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfhap2_err) {
                                echo apsfhap2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_apsf_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfapp2_err) {
                                echo apsfapp2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('HTTPD') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_httpd_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (httpd2_err) {
                                echo httpd2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_mcas_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb2_err) {
                                echo mcasdb2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS HAP') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_mcas_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcashap2_err) {
                                echo mcashap2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_mcas_secondary_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasapp2_err) {
                                echo mcasapp2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_icexs_secondary_${SITE} ${EXTRA_ARGS} -e '{\"active_site\": true}'"
                            } catch (icexs2_err) {
                                echo icexs2_err.getMessage ()
                            }
                        }
                    }
                }
                stage('NRT DB') {
                    steps {
                        script {
                            try {
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_nrt_${SITE} ${EXTRA_ARGS} -e '{\"start_service\": false}'"
                            } catch (nrtdb_err) {
                                echo nrtdb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Activate Databases?') {
            steps {
                input message:'Activate Databases?'
            }
        }
        stage('Activate Databases') {
            parallel {
                stage('APSF DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_apsf_both_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
                stage('MCAS DB') {
                    steps {
                        sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -t failover_postgres_mcas_both_${SITE} -f 1 ${EXTRA_ARGS}"
                    }
                }
            }
        }
    }
}
