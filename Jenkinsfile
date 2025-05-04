pipeline {
    agent any
    environment {
        // Define Harbor registry details
        REGISTRY = '192.168.48.131:8081'
        REPO = 'library/node-js-sample'
        IMAGE_NAME = "${REGISTRY}/${REPO}"
        // Generate a unique tag (e.g., v1.0.0, v1.0.1, etc.)
        TAG = "v1.0.${env.BUILD_NUMBER}"
        // Credentials IDs from Jenkins
        HARBOR_CREDENTIALS = credentials('harbor-credentials')
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }
    stages {
        stage('Checkout') {
            steps {
                // Clone the GitHub repo
                git url: 'https://github.com/pratham7289/Argocd-Pipeline.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                script {
                    docker.build("${IMAGE_NAME}:${TAG}")
                }
            }
        }
        stage('Push to Harbor') {
            steps {
                // Log in to Harbor and push the image
                script {
                    docker.withRegistry("http://${REGISTRY}", 'harbor-credentials') {
                        docker.image("${IMAGE_NAME}:${TAG}").push()
                    }
                }
            }
        }
        stage('Update Manifest') {
            steps {
                // Update the image tag in k8s/deployment.yaml
                sh """
                    sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${TAG}|' k8s/deployment.yaml
                    git config --global user.email "jenkins@example.com"
                    git config --global user.name "Jenkins"
                    git add k8s/deployment.yaml
                    git commit -m "Update image tag to ${TAG}"
                    git push https://${GITHUB_CREDENTIALS}@github.com/pratham7289/Argocd-Pipeline.git main
                """
            }
        }
    }
    post {
        always {
            // Clean up Docker images to save space
            sh "docker rmi ${IMAGE_NAME}:${TAG} || true"
        }
    }
}
