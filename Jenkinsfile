pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository'
                git 'https://github.com/hftamayo/devopsbc2023.git'
            }
        }
        stage('Run tests') {
            steps {
                echo 'Running unit tests'
                sh '''
                    if [ -d "tests" ] && [ -n "$(ls -A tests/*.py 2>/dev/null)" ]; then
                        python -m unittest discover -s tests
                    else
                        echo "No tests found"
                    fi
                '''
            }
        }
        stage('Build image') {
            steps {
                echo 'Building the image'
                sh 'docker build -t ch03fe_vote:stable .'
            }
        }
        stage('Push image') {
            steps {
                echo 'Pushing the image'
                withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                    sh '''
                        echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                        docker push $DOCKER_HUB_USERNAME/ch03fe_vote:latest
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying the frontend'
                sh '''
                    if [ -f "k8s/frontend.yaml" ]; then
                        export DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME
                        envsubst < k8s/frontend.yaml | kubectl apply -f -
                    else
                        echo "No deployment file found"
                    fi
                '''
            }
        }
    }
}