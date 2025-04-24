pipeline {
  agent any

  environment {
    DOCKER_REPO     = 'lavi324/public1-frontend'
    HELM_OCI_REG    = 'oci://docker.io/lavi324/public1-frontend-helm-chart'
    DOCKER_CREDS    = 'docker-hub-creds'
    GIT_CREDS       = 'github-creds'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/lavi324/Public1.git',
            credentialsId: "${GIT_CREDS}"
      }
    }

    stage('Bump Versions') {
      steps {
        script {
          // Run the external increment script and capture output :contentReference[oaicite:5]{index=5}
          def props = sh(
            script: 'scripts/increment_version.sh',
            returnStdout: true
          ).trim()

          // Parse lines like IMAGE_TAG=1.1 and CHART_VERSION=1.0.1
          props.split("\n").each { line ->
            def (k, v) = line.tokenize('=')
            env."${k}" = v
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_CREDS}",
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker build -t $DOCKER_REPO:${IMAGE_TAG} ./frontend   # build from frontend/ :contentReference[oaicite:6]{index=6}
            docker push $DOCKER_REPO:${IMAGE_TAG}                   # push to Docker Hub :contentReference[oaicite:7]{index=7}
          '''
        }
      }
    }

    stage('Package & Push Helm Chart') {
      steps {
        sh '''
          helm lint Public1-frontend-helm-chart               # validate chart :contentReference[oaicite:8]{index=8}
          helm package Public1-frontend-helm-chart            # produces *.tgz
          helm push Public1-frontend-helm-chart-${CHART_VERSION}.tgz $HELM_OCI_REG  # OCI push :contentReference[oaicite:9]{index=9}
        '''
      }
    }
  }

  post {
    success { echo '✅ CI pipeline completed.' }
    failure { echo '❌ CI pipeline failed.' }
  }
}
