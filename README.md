
# Deploying a Web App with Jenkins, Docker, AWS, PostgreSQL, and Grafana

This project involves the deployment of a web application using a React frontend and a Spring Boot backend connected to a PostgreSQL database. The application is hosted on an Ubuntu EC2 instance using Docker, with continuous integration and deployment (CI/CD) managed by Jenkins. The Docker images are built and pushed to AWS ECR. The deployed application is monitored using Grafana to capture logs and server metrics.
## Technologies Used

- Frontend: React.js
- Backend: Spring Boot
- Database: PostgreSQL
- CI/CD: Jenkins
- Frontend: React.js
- Containerization: Docker
- Cloud Services: AWS EC2, AWS ECR , IAM
- Monitoring: Grafana


## Install Jenkins on EC2

SSH into your EC2 instance and install Jenkins:

```bash
sudo apt update
sudo apt install openjdk-11-jdk
sudo apt install wget
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee -a /etc/apt/trusted.gpg.d/jenkins.asc
sudo sh -c 'wget -q -O /etc/apt/sources.list.d/jenkins.list https://pkg.jenkins.io/debian/jenkins.io.list'
sudo apt update
sudo apt install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

```
    
## Create and Configure PostgreSQL Database on AWS

 - Create a PostgreSQL instance on Amazon RDS.
 - Update your Spring Boot backend to connect to the RDS database.

## Build Web App

- Frontend: Create a React application for the UI.
- Backend: Develop a Spring Boot backend to fetch and serve data from the PostgreSQL database.
- Push both frontend and backend code to their respective Git repositories.
- my frontend : https://github.com/imabhosale/Devops-task-frontend
## JenkinsFile

Login to AWS ECR for Backend

```bash
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

```

 Login to AWS ECR for Frontend

```bash
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

```

Clone Backend Git Repository

```bash
  stage('Cloning Backend Git') {
    steps {
        dir('backend') {
            checkout([$class: 'GitSCM', 
                      branches: [[name: '*/main']], 
                      userRemoteConfigs: [[url: 'https://github.com/your-repo/backend-repo.git']]])
        }
    }
}

```

 Clone Frontend Git Repository

```bash
  stage('Cloning Frontend Git') {
    steps {
        dir('frontend') {
            checkout([$class: 'GitSCM', 
                      branches: [[name: '*/main']], 
                      userRemoteConfigs: [[url: 'https://github.com/your-repo/frontend-repo.git']]])
        }
    }
}

```

Build Docker Image for Backend

```bash
 stage('Building Backend image') {
    steps {
        dir('backend') {
            script {
                backendImage = docker.build("${BACKEND_REPO_NAME}:${BACKEND_IMAGE_TAG}", "-f Dockerfile .")
            }
        }
    }
}

```

 Build Docker Image for Frontend

```bash
 stage('Building Frontend image') {
    steps {
        dir('frontend') {
            script {
                frontendImage = docker.build("${FRONTEND_REPO_NAME}:${FRONTEND_IMAGE_TAG}", "-f Dockerfile .")
            }
        }
    }
}

```

Push Backend Image to AWS ECR
```bash
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

```
 Push Frontend Image to AWS ECR

```bash
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

```
Deploy Backend to EC2

```bash
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

```
 Deploy Frontend to EC2

```bash
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

```



## Monitoring

We use Grafana to monitor application metrics, such as CPU usage, response times, and instance health. It tracks logs and resource usage for both backend and frontend services, deployed inside containers. Grafana provides real-time insights into system performance and helps detect potential issues quickly.



## 🚀 Application Url
http://13.233.124.207:3000/contacts


## Monitoring URL

http://35.154.66.198:3000/d/AWSEc2000/aws-ec2?orgId=1&from=now-24h&to=now&timezone=browser&var-datasource=cebj0y4z72vpce&var-region=ap-south-1&var-instancename=devops-task-larger&var-instanceid=i-0ec6c053fdebf96e1&var-volumeid=vol-0f301b060a9d0489f&var-instancetype=t2.large