pipeline {
    agent any

    environment {
        DOCKER_REPO = 'lavi324/public1-frontend'
        HELM_REPO = 'oci://lavi324/public1-frontend-helm-chart'
        IMAGE_NAME = 'public1-frontend'
        CHART_NAME = 'public1-frontend-helm-chart'
        GIT_CREDENTIALS_ID = 'github'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        USER_EMAIL = 'lavialduby@gmail.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Increment Version') {
            steps {
                sh 'chmod +x scripts/increment_version.sh'
                sh './scripts/increment_version.sh'
            }
        }

        stage('Git Commit & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
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

        stage('Build Docker Image') {
            steps {
                script {
                    def newTag = sh(script: "awk -F ':' '/image:/ {print \$2}' public1-frontend-helm-chart/templates/frontend-app.yaml | tr -d ' '", returnStdout: true).trim()
                    sh "docker build -t ${DOCKER_REPO}:${newTag} frontend/"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_REPO}:${newTag}
                    '''
                }
            }
        }

        stage('Package Helm Chart') {
            steps {
                script {
                    def newTag = sh(script: "awk -F ':' '/image:/ {print \$2}' public1-frontend-helm-chart/templates/frontend-app.yaml | tr -d ' '", returnStdout: true).trim()
                    sh "helm package public1-frontend-helm-chart --version ${newTag} --app-version ${newTag}"
                }
            }
        }

        stage('Push Helm Chart') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        helm push ${CHART_NAME}-${newTag}.tgz ${HELM_REPO}
                    '''
                }
            }
        }
    }
}
