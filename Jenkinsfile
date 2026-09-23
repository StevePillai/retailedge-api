pipeline {
  agent any

  options {
    disableConcurrentBuilds()          // two deployments must never run at the same time
    timeout(time: 30, unit: 'MINUTES')
  }

  parameters {
    choice(name: 'ENV', choices: ['staging', 'production'], description: 'Target environment')
    string(name: 'COMMIT_SHA', defaultValue: '', description: 'Commit to deploy (GitHub Actions fills this in)')
  }

  environment {
    ECR_REGISTRY       = '905630096449.dkr.ecr.ap-south-1.amazonaws.com'
    IMAGE_NAME         = 'retailedge-api'
    AWS_REGION         = 'ap-south-1'
    AWS_DEFAULT_REGION = 'ap-south-1'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.ENV = params.ENV ?: 'staging'
          def sha = params.COMMIT_SHA ?: ''
          if (sha ==~ /[0-9a-f]{7,40}/) {
            sh "git checkout ${sha}"
          }
          env.IMAGE_TAG = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
          echo "Deploying ${env.IMAGE_NAME}:${env.IMAGE_TAG} to ${env.ENV}"
        }
      }
    }

    stage('Install & Test') {
      agent {
        docker {
          image 'node:20-alpine'
          reuseNode true
          args '-e npm_config_cache=/tmp/.npm'
        }
      }
      steps {
        sh 'npm ci'
        sh 'npm test'
      }
    }

    stage('Docker Build') {
      steps {
        sh 'docker build -t $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Integration Test') {
      steps {
        sh '''
          CID=$(docker run -d -p 3100:3000 -e APP_VERSION=$IMAGE_TAG $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG)
          trap "docker rm -f $CID" EXIT
          sleep 5
          curl -fsS http://localhost:3100/health
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION \
            | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker push $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
          if [ "$ENV" = "production" ]; then
            docker tag  $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG $ECR_REGISTRY/$IMAGE_NAME:latest
            docker push $ECR_REGISTRY/$IMAGE_NAME:latest
          fi
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform init -input=false'
          sh 'terraform workspace select $ENV || terraform workspace new $ENV'
          sh 'terraform apply -auto-approve -input=false -var-file=env/${ENV}.tfvars -var="image_tag=$IMAGE_TAG"'
          script {
            env.EC2_PUBLIC_IP = sh(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
          }
        }
      }
    }

    stage('Ansible Deploy') {
      steps {
        dir('ansible') {
          withCredentials([
            sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY'),
            file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
          ]) {
            sh '''
              echo "[app_servers]" > inventory/${ENV}.ini
              echo "${EC2_PUBLIC_IP} ansible_user=ec2-user" >> inventory/${ENV}.ini
              ansible-playbook -i inventory/${ENV}.ini playbooks/deploy.yml \
                --private-key "$SSH_KEY" \
                --vault-password-file "$VAULT_PASS_FILE" \
                -e "image_tag=$IMAGE_TAG"
            '''
          }
        }
      }
    }

    stage('Health Check') {
      steps {
        script {
          try {
            sh 'sleep 15 && curl -fsS --retry 5 --retry-delay 5 --retry-connrefused http://$EC2_PUBLIC_IP:3000/health'
          } catch (err) {
            echo 'Health check failed - rolling back to the previous release'
            dir('ansible') {
              withCredentials([
                sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY'),
                file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
              ]) {
                sh '''
                  ansible-playbook -i inventory/${ENV}.ini playbooks/rollback.yml \
                    --private-key "$SSH_KEY" \
                    --vault-password-file "$VAULT_PASS_FILE"
                '''
              }
            }
            error('Health check failed. Rolled back to the previous release.')
          }
        }
      }
    }
  }

  post {
    success { notify('#deployments', 'good', "Deployed: ${env.IMAGE_TAG} to ${env.ENV}") }
    failure { notify('#alerts', 'danger', "FAILED: ${env.IMAGE_TAG} (${env.ENV})") }
    always  { sh 'docker image prune -f || true' }
  }
}

// Sends a Slack message, but never breaks the build if Slack is not set up yet
def notify(String channel, String color, String message) {
  try {
    slackSend channel: channel, color: color, message: message
  } catch (err) {
    echo "Slack is not configured, skipping notification: ${message}"
  }
}
