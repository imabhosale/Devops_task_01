pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "211125753995"  // Replace with your AWS account ID
        AWS_DEFAULT_REGION = "ap-south-1"  // Replace with your AWS ECR region
        IMAGE_REPO_NAME = "backend-repo"  // Replace with your ECR repo name
        BACKEND_IMAGE_TAG = "backend-latest"  // Backend image tag
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        BACKEND_IP = "13.233.124.207"  // Updated IP of your EC2 instance
    }

    stages {
        // Logging into AWS ECR
        stage('Logging into AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        // Use AWS credentials to log in to ECR
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                            docker login --username AWS --password-stdin ${REPOSITORY_URI}
                        """
                    }
                }
            }
        }

        // Cloning the Git repository for backend
        stage('Cloning Backend Git') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          userRemoteConfigs: [[url: 'https://github.com/imabhosale/Devops_task_01.git']]])
            }
        }

        // Building Backend Docker image
        stage('Building Backend image') {
            steps {
                script {
                    // Use the correct path for the Dockerfile at the root of the repo
                    backendImage = docker.build("${IMAGE_REPO_NAME}-backend:${BACKEND_IMAGE_TAG}", "-f Dockerfile .")
                }
            }
        }

        // Pushing Backend image to ECR
        stage('Pushing Backend to ECR') {
            steps {
                script {
                    sh "docker tag ${IMAGE_REPO_NAME}-backend:${BACKEND_IMAGE_TAG} ${REPOSITORY_URI}:${BACKEND_IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:${BACKEND_IMAGE_TAG}"
                }
            }
        }

        // Deploying Backend to EC2 instance inside a Docker container
        stage('Deploying Backend') {
            steps {
                script {
                    // Use the stored SSH private key from Jenkins credentials
                    withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ec2-key', keyFileVariable: 'SSH_KEY')]) {
                        // SSH into the EC2 instance and deploy the backend
                        sh """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${BACKEND_IP} '
                                echo "Connected to EC2 instance for Backend Deployment" &&
                                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 211125753995.dkr.ecr.ap-south-1.amazonaws.com &&
                                docker pull ${REPOSITORY_URI}:${BACKEND_IMAGE_TAG} &&
                                docker stop backend-container || true &&
                                docker rm backend-container || true &&
                                docker run -d --name backend-container -p 8082:7517 ${REPOSITORY_URI}:${BACKEND_IMAGE_TAG}
                            '
                        """
                    }
                }
            }
        }

    }
}
