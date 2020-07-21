// Shared UPF - Pipeline to patch all servers in uat2

// Use this for testing
//        EXTRA_ARGS = "-e server_shutdown_uptime=2000000 -e to_email=first.last@aciworldwide.com -e '{\"stop_service\": false,\"stop_jboss\": false}'"

pipeline {
    agent {label 'master'}
    environment {
        PB_NAME = "${REGION == null ? "playbook${ENVIRONMENT}.yaml" : "playbook${ENVIRONMENT}${REGION}.yaml"}"
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/SharedUPF_Platform_Patching/${PB_NAME}"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/${ENVIRONMENT}"
        EXTRA_ARGS = "-e server_shutdown_uptime=2000000 -e to_email=ray.spiva@aciworldwide.com -e '{\"stop_service\": false,\"stop_jboss\": false}'"
    }
    stages {
        stage('Patch?') {
            steps {
                input message:'Patch?'
            }
        }
        stage('Patch') {
            parallel {
                stage('APSF DB') {
                    steps {
                        script {
                            try {
                                sh "sleep 300"
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_apsf_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_apsf_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_apsf_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_httpd_${SITE} ${EXTRA_ARGS}"
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
                                sh "sleep 300"
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_mcas_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_haproxy_mcas_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_mcas_${SITE} ${EXTRA_ARGS}"
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
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_icexs_${SITE} ${EXTRA_ARGS}"
                            } catch (icexs1_err) {
                                echo icexs1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('NRT DB') {
                    steps {
                        script {
                            try {
                                sh "sleep 300"
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_nrt_${SITE} ${EXTRA_ARGS}"
                            } catch (nrtdb_err) {
                                echo nrtdb_err.getMessage ()
                            }
                        }
                    }
                }
                stage('Upgrade DB') {
                    steps {
                        script {
                            try {
                                sh "sleep 300"
                                sh "/usr/bin/ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t patch_postgres_upgrade_${SITE} ${EXTRA_ARGS}"
                            } catch (upgradedb_err) {
                                echo upgradedb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
    }
}
