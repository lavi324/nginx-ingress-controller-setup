pipeline {
  agent {
    kubernetes {
      label 'gke-agent'
      defaultContainer 'gke-agent'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: gke-agent
spec:
  serviceAccountName: jenkins-agent-sa
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:4.11-4-jdk11
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
      resources:
        limits:
          memory: 512Mi
    - name: gke-agent
      image: docker.io/lavi324/gke_agent:1.0
      imagePullPolicy: IfNotPresent
      command:
        - cat
      tty: true
"""
    }
  }

  environment {
    DOCKER_REPO           = 'lavi324/public1-frontend'
    HELM_REPO             = 'oci://lavi324/public1-frontend-helm-chart'
    GIT_CREDENTIALS_ID    = 'github'
    DOCKER_CREDENTIALS_ID = 'dockerhub'
    USER_EMAIL            = 'lavialduby@gmail.com'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Increment Version') {
      steps {
        sh 'chmod +x scripts/increment_version.sh'
        sh './scripts/increment_version.sh'
      }
    }

    stage('Git Commit & Push') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${GIT_CREDENTIALS_ID}",
          usernameVariable: 'GIT_USERNAME',
          passwordVariable: 'GIT_PASSWORD'
        )]) {
          sh '''
            git config user.name "$GIT_USERNAME"
            git config user.email "$USER_EMAIL"
            git add .
            git commit -m "chore: increment versions"
            git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/lavi324/Public1.git HEAD:main
          '''
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          def newTag = sh(
            script: "awk -F ':' '/image:/ {print \$2}' public1-frontend-helm-chart/templates/frontend-app.yaml | tr -d ' '",
            returnStdout: true
          ).trim()
          // all steps run in the gke-agent container by default
          withCredentials([usernamePassword(
            credentialsId: "${DOCKER_CREDENTIALS_ID}",
            usernameVariable: 'DOCKER_USERNAME',
            passwordVariable: 'DOCKER_PASSWORD'
          )]) {
            sh """
              docker build -t ${DOCKER_REPO}:${newTag} frontend/
              echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
              docker push ${DOCKER_REPO}:${newTag}
            """
          }
        }
      }
    }

    stage('Package & Push Helm Chart') {
      steps {
        script {
          def newTag = sh(
            script: "awk -F ':' '/image:/ {print \$2}' public1-frontend-helm-chart/templates/frontend-app.yaml | tr -d ' '",
            returnStdout: true
          ).trim()
          withCredentials([usernamePassword(
            credentialsId: "${DOCKER_CREDENTIALS_ID}",
            usernameVariable: 'DOCKER_USERNAME',
            passwordVariable: 'DOCKER_PASSWORD'
          )]) {
            sh """
              helm package public1-frontend-helm-chart --version ${newTag} --app-version ${newTag}
              echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
              helm push public1-frontend-helm-chart-${newTag}.tgz ${HELM_REPO}
            """
          }
        }
      }
    }
  }
}
