// AOD AutomatedGit Pull Pipeline
pipeline {
    agent {label 'nxipfappansv001'}
    environment {
        AUTOMATION_MSG = 'Automated Git Commit - Jenkins Pipeline'
    }

// change Directory
stages {
    stage('Stage 0 - Change Directory') {
        steps {
            echo "Change to ansible git repo directory "
            dir('/apps/infra_ansible'){
            sh "pwd"
            }
        }
    }

// Git Auto Commit
    stage('Stage 1 - Automated git Add - Stage All Uncommitted Files') { // should be ran for tpa nodes
        steps {
            echo "Stage all uncommited files"
            dir ('/apps/infra_ansible'){
            sh "/opt/rh/rh-git29/root/usr/bin/git add --all"
            }
        }
    }

    stage('Stage 2 - Git Commit All Staged Files') { // should be ran for each nodes
        steps {
            echo "Commit All Staged Files in Repository"
            dir ('/apps/infra_ansible'){
            sh "/opt/rh/rh-git29/root/usr/bin/git  diff-index --quiet HEAD || /opt/rh/rh-git29/root/usr/bin/git commit -m 'Automated from Jenkins'"
            }
        }
    }

    stage('Stage 3 - Git Automated Pull feature/infra_test from Infra Code Base') { // should be ran for tpa node
        steps {
            echo "Git Pull Infra Code Base"
            dir ('/apps/infra_ansible'){
            sh "/opt/rh/rh-git29/root/usr/bin/git pull"
            }
        }
    }
    stage('Stage 4 - Git Automated Push feature/infra_test from Infra Code Base') { // should be ran for each nodes
        steps {
            echo "Commit All Staged Files in Repository"
            dir ('/apps/infra_ansible'){
            sh "/opt/rh/rh-git29/root/usr/bin/git push"
            }
        }
    }
  }
}
