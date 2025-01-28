pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = 'backend-repo'
        DOCKER_IMAGE_TAG = 'latest'
        EC2_INSTANCE_IP = '13.232.234.199'
        EC2_PRIVATE_KEY = 'C:\\Users\\abhis\\Downloads\\jenkins-key.pem'
    }

    stages {
        stage('Checkout Backend Code') {
            steps {
                git branch: 'main', url: 'https://github.com/imabhosale/Devops_task_01'
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    docker.build("$ECR_REPOSITORY:$DOCKER_IMAGE_TAG", './backend')
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 211125753995.dkr.ecr.$AWS_REGION.amazonaws.com
                        """
                    }
                    docker.tag("$ECR_REPOSITORY:$DOCKER_IMAGE_TAG", "211125753995.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG")
                    docker.push("211125753995.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG")
                }
            }
        }

        stage('Deploy to Backend EC2') {
            steps {
                script {
                    sh """
                        ssh -i $EC2_PRIVATE_KEY ec2-user@$EC2_INSTANCE_IP 'docker pull 211125753995.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG'
                        ssh -i $EC2_PRIVATE_KEY ec2-user@$EC2_INSTANCE_IP 'docker run -d -p 8080:8080 211125753995.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$DOCKER_IMAGE_TAG'
                    """
                }
            }
        }
    }
}
