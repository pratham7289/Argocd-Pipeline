pipeline {
    agent any
    environment {
        REGISTRY = '192.168.48.131:8081'
        REPO = 'library/node-js-sample'
        IMAGE_NAME = "${REGISTRY}/${REPO}"
        TAG = "v1.0.${env.BUILD_NUMBER}"
        HARBOR_CREDENTIALS = credentials('harbor-credentials')
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/pratham7289/Argocd-Pipeline.git', branch: 'main'
            }
        }
        stage('Verify Workspace') {
            steps {
                sh 'pwd'
                sh 'ls -la'
                sh 'if [ -d k8s ]; then ls -la k8s; else echo "k8s directory not found"; fi'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${TAG}")
                }
            }
        }
        stage('Push to Harbor') {
            steps {
                script {
                    docker.withRegistry("http://${REGISTRY}", 'harbor-credentials') {
                        docker.image("${IMAGE_NAME}:${TAG}").push()
                    }
                }
            }
        }
        stage('Update Manifest') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh """
                        ls -l k8s/deployment.yml
                        sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${TAG}|' k8s/deployment.yml
                        git config --global user.email "jenkins@example.com"
                        git config --global user.name "Jenkins"
                        git add k8s/deployment.yml
                        git commit -m "Update image tag to ${TAG}" || echo "No changes to commit"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/pratham7289/Argocd-Pipeline.git main
                    """
                }
            }
        }
    }
    post {
        always {
            sh "docker rmi ${IMAGE_NAME}:${TAG} || true"
        }
    }
}
