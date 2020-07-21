// IP - Pipeline to patch all servers

// Use this for testing
//        EXTRA_ARGS = "-e server_shutdown_uptime=3000000 -e to_email=first.last@aciworldwide.com -e '{\"stop_service\": false,\"stop_jboss\": false}'"

pipeline {
    agent {label 'lmuatanssrv01'}
    environment {
        PB_NAME = "playbookuat2.yaml"
        PLAYBOOK = "/apps/infra_ansible/tasks/IP_Platform_Patching/${PB_NAME}"
        INVENTORY = "/apps/infra_ansible/environments/${ENVIRONMENT}"
        EXTRA_ARGS = "-e to_email=first.last@aciworldwide.com"
    }
    stages {
        stage('Stop Applications?') {
            steps {
                input message:'Stop Applications?'
            }
        }
        stage('Stop Applications') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_apsf_${SITE} ${EXTRA_ARGS}"
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
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_httpd_${SITE} ${EXTRA_ARGS}"
                            } catch (httpd1_err) {
                                echo httpd1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasapp1_err) {
                                echo mcasapp1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MQ') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_mq_${SITE} ${EXTRA_ARGS}"
                            } catch (mq1_err) {
                                echo mq1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_icexs_${SITE} -e '{\"active_site\": ${ACTIVE_SITE}}' ${EXTRA_ARGS}"
                            } catch (icexs1_err) {
                                echo icexs1_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Stop Databases?') {
            steps {
                input message:'Stop Databases?'
            }
        }
        stage('Stop Databases') {
            parallel {
                stage('APSF DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_postgres_apsf_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb1_err) {
                                echo apsfdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_postgres_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb1_err) {
                                echo mcasdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('NRT DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t stop_postgres_nrt_${SITE} ${EXTRA_ARGS}"
                            } catch (nrtdb_err) {
                                echo nrtdb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Start Databases?') {
            steps {
                input message:'Start Databases?'
            }
        }
        stage('Start Databases') {
            parallel {
                stage('APSF DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_postgres_apsf_${SITE} ${EXTRA_ARGS}"
                            } catch (apsfdb1_err) {
                                echo apsfdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_postgres_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasdb1_err) {
                                echo mcasdb1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('NRT DB') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_postgres_nrt_${SITE} ${EXTRA_ARGS}"
                            } catch (nrtdb_err) {
                                echo nrtdb_err.getMessage ()
                            }
                        }
                    }
                }
            }
        }
        stage('Start Applications?') {
            steps {
                input message:'Start Applications?'
            }
        }
        stage('Start Applications') {
            parallel {
                stage('APSF') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_apsf_${SITE} ${EXTRA_ARGS}"
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
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_httpd_${SITE} ${EXTRA_ARGS}"
                            } catch (httpd1_err) {
                                echo httpd1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MCAS') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_mcas_${SITE} ${EXTRA_ARGS}"
                            } catch (mcasapp1_err) {
                                echo mcasapp1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('MQ') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_mq_${SITE} ${EXTRA_ARGS}"
                            } catch (mq1_err) {
                                echo mq1_err.getMessage ()
                            }
                        }
                    }
                }
                stage('ICE-XS') {
                    steps {
                        script {
                            try {
                                sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -f 5 -t start_icexs_${SITE} -e '{\"active_site\": ${ACTIVE_SITE}}' ${EXTRA_ARGS}"
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
