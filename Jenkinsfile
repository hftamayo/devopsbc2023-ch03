/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository'
                git 'https://github.com/hftamayo/devopsbc2023-ch03.git'
            }
        }
        stage('Frontend') {
            stages {
                stage('change to vote directory') {
                    steps {
                        dir('vote') {
                            echo 'Changing to vote directory'
                        }
                    }
                }

                stage('Install dependencies') {
                    steps {
                        echo 'Installing dependencies'
                        sh 'pip install -r requirements.txt'
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

        stage('Worker dotnet microservice') {
            stages {
                stage('change to worker directory') {
                    steps {
                        dir('worker') {
                            echo 'Changing to worker directory'
                        }
                    }
                }

                stage('Restore dependencies') {
                    steps {
                        echo 'Restoring dependencies'
                        sh 'dotnet restore'
                    }
                }

                stage('build docker image') {
                    steps {
                        echo 'Building the docker image for testing'
                        sh 'docker build -t ch03be_worker:stable .'
                    }
                }

                stage('Run worker microservice container') {
                    steps {
                        echo 'Running the worker microservice container'
                        sh 'docker run -d -p 8080:80 --name worker ch03be_worker:stable'
                    }
                }

                stage('Run tests') {
                    steps {
                        echo 'Running worker microservice unit tests'
                        sh 'dotnet test'
                    }
                }

                stage('Push image') {
                    steps {
                        echo 'Pushing the image'
                        withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                            sh '''
                                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                                docker push $DOCKER_HUB_USERNAME/ch03be_worker:latest
                            '''
                        }
                    }
                }

                stage('Deploy') {
                    steps {
                        echo 'Deploying the worker microservice'
                        sh '''
                            if [ -f "k8s/microdotnet.yaml" ]; then
                                export DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME
                                envsubst < k8s/microdotnet.yaml | kubectl apply -f -
                            else
                                echo "No deployment file found"
                            fi
                        '''
                    }
                }
            }
        }


    }
}
