pipeline {
  agent {
    docker {
      image 'maven:3.9.6-eclipse-temurin-17'
    }
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'develop', url: 'https://github.com/SRI-2004/jenkins.git'
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
          docker build -t your-dockerhub-user/your-image:latest .
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
          docker push your-dockerhub-user/your-image:latest
        '''
      }
    }

    stage('Deploy to AWS EC2') {
      steps {
        sshagent (credentials: ['ec2-ssh-key']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ec2-user@<EC2-IP> '
              docker pull your-dockerhub-user/your-image:latest &&
              docker stop api || true &&
              docker rm api || true &&
              docker run -d --name api -p 8080:8080 your-dockerhub-user/your-image:latest
            '
          '''
        }
      }
    }
  }
}
