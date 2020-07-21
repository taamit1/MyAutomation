pipeline {
    agent {label 'master'}
    environment {
        ENVIRONMENT = '/usr/local/var/ansible/lfin/uat_dm/environments/poc' //Proof of Concept Test Environment
        ANSIBLE_PATH = '/usr/local/var/ansible/lfin/uat_dm'
        TPA_PATH = '/usr/local/var/ansible/lfin/uat_dm/files/scripts'
        TPA_NEXUS = '/usr/local/var/ansible/lfin/uat_dm/files/nexus'
        TPAEXEC = '/opt/2ndQuadrant/TPA/bin'
    }

//Development stage 1 will be done without SSL encryption
//Devleopment stage 2 will include SSL encryption
//SSL encryption steps will go here to generate keys before the install

// VRA virtual machine build
stages {
    stage('Stage 0 - Vrealize build of server environment ') {
        steps {
            echo "Deploying VRealize Core Server Deploy"
            sh "/usr/bin/ansible-playbook -i $ENVIRONMENT $ANSIBLE_PATH/tasks/vRealize/playbook.yaml -e send_to=$EMAIL -e NumOfHosts=$NUMHOSTS -e inv_grp=$INVENTORY -e core_cpu=$CORECPU -e core_ram=$CORERAM -e core_stg=$CORESTG -e VmTemplate=$VMTEMPLATE"
        }
    }

// TPA Exec Install & Deploy
    stage('Stage 1 - create tpa and ansible users') { // should be ran for tpa nodes
        steps {
            echo "create tpa and ansible users"
            sh "/usr/bin/ansible-playbook -i $ENVIRONMENT $ANSIBLE_PATH/tasks/Create_users/playbook.yaml -e variable_host=$INVENTORY -e ProxyAddress=$ProxyAddress"
        }
    }

    stage('Stage 2 - Satelite Server / Server Hardening') { // should be ran for each nodes
        steps {
            echo "Configure with Satelite Server / Harden Server"
            sh "/usr/bin/ansible-playbook -i $ENVIRONMENT $ANSIBLE_PATH/tasks/Download_TPA_Pkgs/playbook.yaml -e variable_host=$INVENTORY -e ProxyAddress=$ProxyAddress"
        }
    }

    stage('Stage 3 - Configure MCAS db cluster') { // should be ran for tpa node
        steps {
            echo "Configure MCAS db cluster"
            sh "cat $TPA_PATH/tpapasswd | su -c  '$TPA_PATH/configure_cluster.sh mcas' -s /bin/sh tpa"
        }
    }

    stage('Stage 4 - Prepare & Configure TPAExec Template') { // should be ran for tpa node
        steps {
            echo "Prepare MCAS Cluster Template"
            sh "/usr/bin/ansible-playbook -i $ENVIRONMENT $ANSIBLE_PATH/tasks/Tpa_Exec/playbook.yaml"
        }
    }

    stage('Stage 5 - Clear and Populate Keys in /home/tpa/mcas/known_host file') { // should be ran for each nodes
        steps {
            echo "Download 2ndQuadrant packages"
            sh "/usr/bin/ansible-playbook -i $ENVIRONMENT $ANSIBLE_PATH/tasks/Tpa_Exec/playbook_key.yaml -e variable_host=$INVENTORY -e ProxyAddress=$ProxyAddress"
        }
    }

    stage('Stage 6 - prepare config.yml file, prepare environment, copy hooks') { // should be ran for tpa node
        steps {
            echo "prepare config.yml file, prepare environment, copy hooks"
            sh "cat $TPA_PATH/tpapasswd | su -c '$TPA_PATH/prepare_environment.sh' -s /bin/sh tpa"
        }
    }
    stage('Stage 7 - Provision MCAS db cluster') { // should be ran for tpa node
        steps {
            echo "Provision MCAS db cluster"
            sh "cat $TPA_PATH/tpapasswd | su -c '$TPA_PATH/provision_cluster.sh mcas' -s /bin/sh tpa"
        }
    }

    stage('Stage 8 - Prepare Deploy.yml file') { // should be ran for tpa node
        steps {
            echo "prepare deploy.yml file"
            sh "cat $TPA_PATH/tpapasswd | su -c '$TPA_PATH/prepare_deploy_file.sh mcas' -s /bin/sh tpa"
        }
    }

    stage('Stage 9 - Deploy MCAS db cluster') { // should be rUn for tpa node
        steps {
            echo "Deploy MCAS db cluster"
//            sh "cat $TPA_PATH/tpapasswd | su -c '$TPAEXEC/tpaexec deploy ~/clusters/mcas -e ProxyAddress=$ProxyAddress -vvvv' -s /bin/sh tpa"
            sh "cat $TPA_PATH/tpapasswd | su -c '$TPA_PATH/deploy_cluster.sh mcas' -s /bin/sh tpa"
        }
    }
  }
}
