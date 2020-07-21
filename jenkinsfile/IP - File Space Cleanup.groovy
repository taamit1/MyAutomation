// IP PROD - Pipeline to harden environment with application configurations

pipeline {
    agent {label 'master'}
    environment {
        PLAYBOOK = "/usr/local/var/ansible/lfin/uat_dm/tasks/IP_Disk_Usage_Monitor/playbook.yaml"
        INVENTORY = "/usr/local/var/ansible/lfin/uat_dm/environments/$ENVIRONMENT"
        VARS_BASE = "${ENVIRONMENT == "prod" ? "prodvars.yml" : "testvars.yml"}"
        VARS_FILE = "/usr/local/var/ansible/lfin/uat_dm/vars/$VARS_BASE"
        //SCHEDULE set in Jenkins
    }
    stages {
        stage('File Space Cleanup') {
            parallel {
                stage('Limerick') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t push_appsdumon_limerick -f 100 -e schedule=$SCHEDULE -e '@$VARS_FILE' -vv"
                    }
                }
                stage('London') {
                    steps {
                        sh "/usr/bin/ansible-playbook $PLAYBOOK -i $INVENTORY -t push_appsdumon_london -f 100 -e schedule=$SCHEDULE -e '@$VARS_FILE' -vv"
                    }
                }
            }
        }
    }
}
