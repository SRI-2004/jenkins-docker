pipeline {
  agent {
    docker {
      image 'debian:bullseye' // or ubuntu:20.04
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
  }

  stages {
    stage('Install Build Tools') {
      steps {
        sh '''
        apt-get update
        apt-get install -y maven git docker.io
        '''
      }
    }

    stage('Clone') {
      steps {
        git branch: 'develop', url: 'https://github.com/SRI-2004/jenkins-docker.git'
      }
    }

    stage('Build with Maven') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Docker Build & Push') {
      steps {
        sh '''
        docker build -t your-dockerhub-user/rest-api:latest .
        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
        docker push your-dockerhub-user/rest-api:latest
        '''
      }
    }

    stage('Deploy to AWS EC2') {
      steps {
        sshagent (credentials: ['ec2-ssh-key']) {
          sh '''
          ssh -o StrictHostKeyChecking=no ec2-user@<EC2-IP> '
            docker pull your-dockerhub-user/rest-api:latest &&
            docker stop api || true &&
            docker rm api || true &&
            docker run -d --name api -p 8080:8080 your-dockerhub-user/rest-api:latest
          '
          '''
        }
      }
    }
  }
}
