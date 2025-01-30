pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "211125753995"  // Replace with your AWS account ID
        AWS_DEFAULT_REGION = "ap-south-1"  // Replace with your AWS region
        BACKEND_REPO_NAME = "backend-repo"  // Replace with your backend ECR repository name
        FRONTEND_REPO_NAME = "frontend-repo"  // Replace with your frontend ECR repository name
        BACKEND_IMAGE_TAG = "backend-latest"  // Tag for your backend image
        FRONTEND_IMAGE_TAG = "frontend-latest"  // Tag for your frontend image
        REPOSITORY_URI_BACKEND = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${BACKEND_REPO_NAME}"
        REPOSITORY_URI_FRONTEND = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${FRONTEND_REPO_NAME}"
        BACKEND_IP = "13.233.124.207"  // IP of your EC2 instance for backend
        FRONTEND_IP = "13.233.124.207"  // IP of your EC2 instance for frontend
    }

    stages {
        // Logging into AWS ECR for Backend
        stage('Logging into AWS ECR - Backend') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                            docker login --username AWS --password-stdin ${REPOSITORY_URI_BACKEND}
                        """
                    }
                }
            }
        }

        // Logging into AWS ECR for Frontend
        stage('Logging into AWS ECR - Frontend') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                            docker login --username AWS --password-stdin ${REPOSITORY_URI_FRONTEND}
                        """
                    }
                }
            }
        }

        // Cloning Backend Git repository
        stage('Cloning Backend Git') {
            steps {
                dir('backend') {
                    checkout([$class: 'GitSCM', 
                              branches: [[name: '*/main']], 
                              userRemoteConfigs: [[url: 'https://github.com/imabhosale/Devops_task_01.git']]])
                }
            }
        }

        // Cloning Frontend Git repository
        stage('Cloning Frontend Git') {
            steps {
                dir('frontend') {
                    checkout([$class: 'GitSCM', 
                              branches: [[name: '*/main']], 
                              userRemoteConfigs: [[url: 'https://github.com/imabhosale/Devops-task-frontend.git']]])
                }
            }
        }

        // Building Backend Docker image
        stage('Building Backend image') {
            steps {
                dir('backend') {
                    script {
                        backendImage = docker.build("${BACKEND_REPO_NAME}:${BACKEND_IMAGE_TAG}", "-f Dockerfile .")
                    }
                }
            }
        }

        // Building Frontend Docker image
        stage('Building Frontend image') {
            steps {
                dir('frontend') {
                    script {
                        frontendImage = docker.build("${FRONTEND_REPO_NAME}:${FRONTEND_IMAGE_TAG}", "-f Dockerfile .")
                    }
                }
            }
        }

        // Pushing Backend image to ECR
        stage('Pushing Backend to ECR') {
            steps {
                dir('backend') {
                    script {
                        sh "docker tag ${BACKEND_REPO_NAME}:${BACKEND_IMAGE_TAG} ${REPOSITORY_URI_BACKEND}:${BACKEND_IMAGE_TAG}"
                        sh "docker push ${REPOSITORY_URI_BACKEND}:${BACKEND_IMAGE_TAG}"
                    }
                }
            }
        }

        // Pushing Frontend image to ECR
        stage('Pushing Frontend to ECR') {
            steps {
                dir('frontend') {
                    script {
                        sh "docker tag ${FRONTEND_REPO_NAME}:${FRONTEND_IMAGE_TAG} ${REPOSITORY_URI_FRONTEND}:${FRONTEND_IMAGE_TAG}"
                        sh "docker push ${REPOSITORY_URI_FRONTEND}:${FRONTEND_IMAGE_TAG}"
                    }
                }
            }
        }

        // Deploying Backend to EC2 instance inside Docker container
        stage('Deploying Backend') {
            steps {
                dir('backend') {
                    script {
                        withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ec2-key', keyFileVariable: 'SSH_KEY')]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${BACKEND_IP} '
                                    echo "Connected to EC2 for Backend Deployment" &&
                                    docker ps -q -f name=backend-container | xargs -r docker stop &&
                                    docker ps -aq -f name=backend-container | xargs -r docker rm &&
                                    docker pull ${REPOSITORY_URI_BACKEND}:${BACKEND_IMAGE_TAG} &&
                                    docker run -d --name backend-container -p 8082:7517 ${REPOSITORY_URI_BACKEND}:${BACKEND_IMAGE_TAG}
                                '
                            """
                        }
                    }
                }
            }
        }

        // Deploying Frontend to EC2 instance inside Docker container
        stage('Deploying Frontend') {
            steps {
                dir('frontend') {
                    script {
                        withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ec2-key', keyFileVariable: 'SSH_KEY')]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${FRONTEND_IP} '
                                    echo "Connected to EC2 for Frontend Deployment" &&
                                    docker ps -q -f name=frontend-container | xargs -r docker stop &&
                                    docker ps -aq -f name=frontend-container | xargs -r docker rm &&
                                    docker pull ${REPOSITORY_URI_FRONTEND}:${FRONTEND_IMAGE_TAG} &&
                                    docker run -d --name frontend-container -p 3000:3000 ${REPOSITORY_URI_FRONTEND}:${FRONTEND_IMAGE_TAG}
                                '
                            """
                        }
                    }
                }
            }
        }
    }
}
