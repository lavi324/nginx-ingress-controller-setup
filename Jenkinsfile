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
  securityContext:
    fsGroup: 1000
  serviceAccountName: jenkins

  volumes:
    - name: workspace
      emptyDir: {}
    - name: docker-sock
      emptyDir: {}

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest-jdk17
      args: ['\$(JENKINS_SECRET)','\$(JENKINS_NAME)']
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent
      resources:
        limits:
          memory: 512Mi

    - name: docker-dind
      image: docker:20.10.14-dind
      securityContext:
        privileged: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run

    - name: gke-agent
      image: docker.io/lavi324/gke_agent:1.0
      command: ['cat']
      tty: true
      env:
        - name: DOCKER_HOST
          value: unix:///var/run/docker.sock
      volumeMounts:
        - name: workspace
          mountPath: /home/jenkins/agent
        - name: docker-sock
          mountPath: /var/run
"""
    }
  }

  options { skipDefaultCheckout() }

  environment {
    GIT_CREDENTIALS_ID    = 'github'
    DOCKER_CREDENTIALS_ID = 'dockerhub'
    USER_EMAIL            = 'lavialduby@gmail.com'

    DOCKER_REPO           = 'lavi324/public1-frontend'
    HELM_REPO_URL         = 'oci://registry-1.docker.io/lavi324/public1-frontend-helm-chart'
  }

  stages {
    stage('Checkout & Bump Versions') {
      steps {
        container('gke-agent') {
          withCredentials([usernamePassword(
            credentialsId: GIT_CREDENTIALS_ID,
            usernameVariable: 'GIT_USER',
            passwordVariable: 'GIT_TOKEN'
          )]) {
            sh '''
              rm -rf *
              git clone https://$GIT_USER:$GIT_TOKEN@github.com/lavi324/Public1.git .
              git config --global --add safe.directory "$PWD"
              git config user.name "$GIT_USER"
              git config user.email "$USER_EMAIL"
              chmod +x scripts/increment_version.sh
              ./scripts/increment_version.sh

              git add public1-frontend-helm-chart/templates/frontend-app.yaml \
                      public1-frontend-helm-chart/Chart.yaml
              git commit -m "chore: increment versions"
              git push https://$GIT_USER:$GIT_TOKEN@github.com/lavi324/Public1.git HEAD:main
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('gke-agent') {
          script {
            // pick up the new image tag from your bumped Helm template
            newTag = sh(
              script: "awk -F':' '/image:/ {print \$NF}' public1-frontend-helm-chart/templates/frontend-app.yaml | tr -d ' \\\"'",
              returnStdout: true
            ).trim()

            withCredentials([usernamePassword(
              credentialsId: DOCKER_CREDENTIALS_ID,
              usernameVariable: 'DOCKER_USER',
              passwordVariable: 'DOCKER_PASS'
            )]) {
              sh """
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker build -t ${DOCKER_REPO}:${newTag} frontend/
                docker push ${DOCKER_REPO}:${newTag}
              """
            }
          }
        }
      }
    }

    stage('Package & Push Helm Chart') {
      steps {
        container('gke-agent') {
          script {
            // reuse the same tag for chart version
            chartVersion = newTag
          }
          withCredentials([usernamePassword(
            credentialsId: DOCKER_CREDENTIALS_ID,
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh """
              # Helm OCI login to Docker Hub
              echo "$DOCKER_PASS" | helm registry login registry-1.docker.io \
                                      -u "$DOCKER_USER" --password-stdin

              # package only with --version
              helm package public1-frontend-helm-chart \
                --version ${chartVersion}

              # push the chart to your DockerHub OCI repo
              helm push public1-frontend-helm-chart-${chartVersion}.tgz \
                ${HELM_REPO_URL}
            """
          }
        }
      }
    }
  }
}
