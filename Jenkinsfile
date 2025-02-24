pipeline {
    agent any

    tools {
        terraform 'Terraform'  // Ensure this matches the name set in Global Tool Configuration
    }

    environment {
        TF_VAR_region = 'us-east-1'                 // Terraform region variable
        TF_VAR_key_name = 'mykey'                   // Terraform key pair
        TF_IN_AUTOMATION = 'true'                   // Disable interactive prompts for Terraform
        ANSIBLE_HOST_KEY_CHECKING = 'False'         // Disable SSH prompt for Ansible
        ANSIBLE_REMOTE_USER = 'ubuntu'              // Remote SSH user for Ansible
    }

    stages {
        stage('Terraform Init') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('prometheus-terraform') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('prometheus-terraform') {
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('prometheus-terraform') {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    dir('prometheus-roles') {
                        sh 'chmod +x dynamic_inventory.sh'
                        sh 'ansible-playbook -i dynamic_inventory.sh playbook.yml --private-key=$SSH_KEY'
                    }
                }
            }
        }

        stage('Terraform Destroy (Optional)') {
            steps {
                input message: 'Do you want to destroy the infrastructure?', ok: 'Destroy'
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('prometheus-terraform') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs for details.'
        }
    }
}
