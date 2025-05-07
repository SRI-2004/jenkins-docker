pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'develop', url: 'https://github.com/SRI-2004/jenkins-docker.git'
      }
    }

    stage('Build order-service') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-17'
        }
      }
      steps {
        dir('order-service/app') {
          sh 'mvn clean package'
        }
      }
    }

    stage('Build user-service') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-17'
        }
      }
      steps {
        dir('user-service/app') {
          sh 'mvn clean package'
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        sh '''
          docker build -t srinivasansridhar28/order-service:latest order-service/app
          docker build -t srinivasansridhar28/user-service:latest user-service/app

          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin

          docker push srinivasansridhar28/order-service:latest
          docker push srinivasansridhar28/user-service:latest
        '''
      }
    }
    

    stage('Deploy to AWS EC2') {
      steps {
        sshagent (credentials: ['ec2-ssh-key']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ec2-user@51.20.60.31 '
              docker pull srinivasansridhar28/order-service:latest &&
              docker stop order-service || true &&
              docker rm order-service || true &&
              docker run -d --name order-service -p 8081:8080 srinivasansridhar28/order-service:latest

              docker pull srinivasansridhar28/user-service:latest &&
              docker stop user-service || true &&
              docker rm user-service || true &&
              docker run -d --name user-service -p 8082:8080 srinivasansridhar28/user-service:latest
            '
          '''
        }
      }
    }
  }
}
