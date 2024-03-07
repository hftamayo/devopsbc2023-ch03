/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository'
                git branch: 'main', url: 'https://github.com/hftamayo/devopsbc2023-ch03.git'
            }
        }

        stage('Database layer') {
            stages {
                stage('Deploy postgres') {
                    steps {
                        echo 'Deploying postgres'
                        sh '''
                            if [ -f "k8s/db/postgres_deployment.yaml" ]; then
                                kubectl apply -f k8s/db/postgres_deployment.yaml
                                if [ $? -eq 0 ]; then
                                    echo "Deployment applied successfully"
                                    if [ -f "k8s/db/postgres_service.yaml" ]; then
                                        kubectl apply -f k8s/db/postgres_service.yaml
                                        if [ $? -eq 0 ]; then
                                            echo "Service applied successfully"
                                        else
                                            echo "Failed to apply service"
                                            exit 1
                                        fi
                                    else
                                        echo "No service file found"
                                    fi
                                else
                                    echo "Failed to apply deployment"
                                    exit 1
                                fi
                            else
                                echo "No deployment file found"
                            fi
                        '''
                    }
                }
                stage('Deploy redis') {
                    steps {
                        echo 'Deploying redis'
                        sh '''
                            if [ -f "k8s/db/redis_deployment.yaml" ]; then
                                kubectl apply -f k8s/db/redis_deployment.yaml
                                if [ $? -eq 0 ]; then
                                    echo "Deployment applied successfully"
                                    if [ -f "k8s/db/redis_service.yaml" ]; then
                                        kubectl apply -f k8s/db/redis_service.yaml
                                        if [ $? -eq 0 ]; then
                                            echo "Service applied successfully"
                                        else
                                            echo "Failed to apply service"
                                            exit 1
                                        fi
                                    else
                                        echo "No service file found"
                                    fi
                                else
                                    echo "Failed to apply deployment"
                                    exit 1
                                fi
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
                        }                        // code inside the steps block
                    }
                }

                stage('build and test of the worker microservice docker container') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building worker microservice docker image for testing'
                            sh 'docker buildx build --platform linux/amd64 -t ch03be_worker:test --target test --load .'
                            sh 'docker run --name worker_test -d ch03be_worker:test'
                            catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                                echo 'Running worker microservice test routines'
                                sh 'docker exec -it worker_test dotnet test'
                            }
                        }
                    }
                    post {
                        always {
                            echo 'Stopping the worker microservice test container'
                            sh 'docker stop worker_test'
                        }
                        success {
                            echo 'Worker microservice test docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build worker microservice test Docker image'
                        }
                    }
                }

                stage('build worker microservice docker image for production') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building worker microservice docker image for production'
                            sh 'docker build -t ch03be_worker:stable-1.0.0 . --target production --load .'
                            sh "docker tag ch03be_worker:stable-1.0.0 hftamayo/ch03be_worker:stable-1.0.0"
                        }
                    }
                    post {
                        success {
                            echo 'Worker microservice production docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build worker microservice production Docker image'
                        }
                    }
                }

                stage('Push worker microservice production image') {
                    steps {
                        echo 'Pushing stable worker microservice image'
                        withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                            sh '''
                                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                                docker push $DOCKER_HUB_USERNAME/ch03be_worker:stable-1.0.0
                            '''
                        }
                    }
                }

                stage('Deploy worker microservice production k8s cluster') {
                    steps {
                        echo 'Deploying the worker microservice'
                        sh '''
                            if [ -f "k8s/microdotnet.yaml" ]; then
                                export DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME
                                envsubst < k8s/microdotnet.yaml | microk8s.kubectl apply -f -
                            else
                                echo "No deployment file found"
                            fi
                        '''
                    }
                }
            }
        }

        stage('Result microservice nodejs') {
            stages {
                stage('change to result directory') {
                    steps {
                        dir('result') {
                            echo 'Changing to result directory'
                        }
                    }
                }

                stage('build and test of the result microservice docker container') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building result microservice docker image for testing'
                            sh 'docker build -t ch03be_result:test . --target test --load .'
                            sh 'docker run --name result_test -d ch03be_result:test'
                            catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                                echo 'Running result microservice test routines'
                                sh 'docker exec -it result_test npm test'
                            }
                        }
                    }
                    post {
                        always {
                            echo 'Stopping the result microservice test container'
                            sh 'docker stop result_test'
                        }
                        success {
                            echo 'Result microservice test docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build result microservice test Docker image'
                        }
                    }
                }

                stage('build result microservice docker image for production') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building result microservice docker image for production'
                            sh 'docker build -t ch03be_result:stable-1.0.0 . --target production --load .'
                            sh 'docker tag ch03be_result:stable-1.0.0 hftamayo/ch03be_result:stable-1.0.0'
                        }
                    }
                    post {
                        success {
                            echo 'Result microservice production docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build result microservice production Docker image'
                        }
                    }
                }

                stage('Push result microservice production image') {
                    steps {
                        echo 'Pushing the result microservice production image'
                        withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                            sh '''
                                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                                docker push $DOCKER_HUB_USERNAME/ch03be_result:stable-1.0.0
                            '''
                        }
                    }
                }

                stage('Deploy result microservice production k8s cluster') {
                    steps {
                        echo 'Deploying the result microservice'
                        sh '''
                            if [ -f "k8s/micronode.yaml" ]; then
                                export DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME
                                envsubst < k8s/micronode.yaml | microk8s.kubectl apply -f -
                            else
                                echo "No deployment file found"
                            fi
                        '''
                    }
                }
            }
        }

        stage('Frontend python microservice') {
            stages {
                stage('change to vote directory') {
                    steps {
                        dir('vote') {
                            echo 'Changing to vote directory'
                        }
                    }
                }

                stage('build frontend docker image for testing') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building frontend docker image for testing'
                            sh 'docker build -t ch03fe_vote:test --target test --load .'
                            sh 'docker run --name vote_test -d ch03fe_vote:test'
                            catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                                echo 'Running vote microservice test routines'
                                sh 'docker exec -it vote_test pytest'
                            }
                        }
                    }
                    post {
                        always {
                            echo 'Stopping the vote microservice test container'
                            sh 'docker stop vote_test'
                        }
                        success {
                            echo 'Vote microservice test docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build vote microservice test Docker image'
                        }
                    }
                }

                stage('build vote microservice docker image for production') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building vote microservice docker image for production'
                            sh 'docker build -t ch03fe_vote:stable-1.0.0 . --target production --load .'
                            sh 'docker tag ch03fe_vote:stable-1.0.0 hftamayo/ch03fe_vote:stable-1.0.0'
                        }
                    }
                    post {
                        success {
                            echo 'Vote microservice production docker image built successfully'
                        }
                        failure {
                            echo 'Failed to build vote microservice production Docker image'
                        }
                    }
                }

                stage('Push vote microservice production image') {
                    steps {
                        echo 'Pushing the vote microservice production image'
                        withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                            sh '''
                                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                                docker push $DOCKER_HUB_USERNAME/ch03fe_vote:stable-1.0.0
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
                                envsubst < k8s/frontend.yaml | microk8s.kubectl apply -f -
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
