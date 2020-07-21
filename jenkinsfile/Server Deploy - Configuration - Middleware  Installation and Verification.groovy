pipeline {
    agent any
    stages {
        stage('Server Provision') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Provision Server node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/vrealize_deploy/vradeploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e send_to=darryl.plunkett@aciworldwide.com -e NumOfHosts=1 -e core_cpu=2 -e core_ram=8192 -e core_stg=100 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('App 2 ') {
                    steps {
                        echo "Provision Server node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/vrealize_deploy/vradeploy/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e send_to=darryl.plunkett@aciworldwide.com -e NumOfHosts=2-e core_cpu=2 -e core_ram=8192 -e core_stg=100 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
        stage('RHEL Registration and Pre-Install ') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Register & Add RHEL Repo on node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/rhel_deploy/rhel7_pre-install/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -e vhost=node1 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('App 2') {
                    steps {
                        echo "Register & Add RHEL Rep on node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/rhel_deploy/rhel7_pre-install/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc  -e vhost=node2 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
        stage('Install Zabbix Monitor Agent') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Install Zabbix Agent on node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/monitor_zabbix_agent/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -e vhost=node1 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('App 2') {
                    steps {
                        echo "Install Zabbix Agent on node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/monitor_zabbix_agent/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc  -e vhost=node2 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
        stage('Websphere Application Server Installation') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Deploying UOB on node1"
                        sleep time: 15, unit: 'SECONDS'
                    }
                }
                stage('App 2') {
                    steps {
                        echo "Deploying UOB on node2"
                        sleep time: 25, unit: 'SECONDS'
                    }
                }
                stage('Web 1') {
                    steps {
                        echo "Websphere Application Server PreRequisite to node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/prereq/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node1 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('Web 2') {
                    steps {
                        echo "Websphere Application Server Pre-Requisite to node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/prereq/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node2 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('Web 1') {
                    steps {
                        echo "Websphere Application Server Update Install to node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/updinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node1 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('Web 2') {
                    steps {
                        echo "Websphere Application Server Update Install to node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/updinstall/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node2 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('Web 1') {
                    steps {
                        echo "Websphere Application Server DMGR to node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/webspheredm/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node1 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('Web 2') {
                    steps {
                        echo "Websphere Application Server NodeAgent to node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/websphere/websphereba/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node2 -e fi_list=fimuob -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
        stage('Post Installer') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Removing maintenance page on node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -t down -f 5 -e vhost=node1 -e fi_list=fimuob -e operation=down -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('App 2') {
                    steps {
                        echo "Removing maintenance page on node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm_maint/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -t down -f 5 -e vhost=node2 -e fi_list=fimuob -e operation=down -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
        stage('Server Restart') {
            parallel {
                stage('App 1') {
                    steps {
                        echo "Restarting node1"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node1 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
                stage('App 2') {
                    steps {
                        echo "Restarting node2"
                        sh "/usr/bin/ansible-playbook /usr/local/var/ansible/lfin/uat_dm/roles/awsm_restart/playbook.yaml -i /usr/local/var/ansible/lfin/uat_dm/environments/poc -f 5 -e vhost=node2 -e ansible_ssh_user=svc_ansible -e ansible_ssh_private_key_file=/usr/local/var/ansible/lfin/uat_dm/keys/common/ansible"
                    }
                }
            }
        }
    }
}
