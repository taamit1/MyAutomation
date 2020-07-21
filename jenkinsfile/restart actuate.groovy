// restart actuate

pipeline {
    agent {label 'master'}
    environment {
        ACT = "muiap01"
        FI_NAME = "fimuobi1"
    }
    stages {
        stage('Actuate Stop') {
            steps {
                echo "Stopping Actuate services on $ACT"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t stop_actuate -f 5 -e vhost=$ACT -e finame=$FI_NAME"
            }
        }
        stage('Actuate Start') {
            steps {
                echo "Starting Actuate services on $ACT"
                sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/actuate/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/pre-prod -t start_actuate -f 5 -e vhost=$ACT -e finame=$FI_NAME"
            }
        }
    }
}
