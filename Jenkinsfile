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

        stage('Database layer') {
            stages {
                stage('Deploy postgres') {
                    echo 'Deploying postgres'
                    steps {
                        sh '''
                            if [ -f "k8s/postgres.yaml" ]; then
                                kubectl apply -f k8s/postgres.yaml
                            else
                                echo "No deployment file found"
                            fi
                        '''
                    }
                }

                stage('Deploy redis') {
                    echo 'Deploying redis'
                    steps {
                        sh '''
                            if [ -f "k8s/redis.yaml" ]; then
                                kubectl apply -f k8s/redis.yaml
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

                stage('build docker image for testing') {
                    steps {
                        echo 'Building the docker image for testing'
                        sh 'docker buildx build --platform linux/amd64 -t ch03be_worker:test --target test --load .'
                    }
                }

                stage('Run worker test microservice container') {
                    steps {
                        echo 'Running the worker test microservice container'
                        script {
                            def result = sh(script: 'docker run -d -p 8080:80 --name worker ch03be_worker:test', returnStdout: true)
                            def containerId = result.trim()
                            env.WORKER_CONTAINER_ID = containerId
                        }
                    }
                    post {
                        failure {
                            echo 'Stopping the worker microservice container due to a failure'
                            sh 'docker stop worker'
                        }
                    }
                }

                stage('Run worker testing routines') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            echo 'Running worker microservice test routines'
                            sh "docker exec -it ${env.WORKER_CONTAINER_ID} dotnet test"
                        }
                    }
                    post {
                        always {
                            echo 'Stopping the worker microservice test container'
                            sh 'docker stop ${env.WORKER_CONTAINER_ID}'
                        }
                        failure {
                            echo 'No tests were found'
                        }
                    }                    
                }

                stage('Build worker microservice image for production') {
                    steps {
                        catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                            echo 'Building worker microservice docker image for production'
                            sh "docker build -t ch03be_worker:stable-1.0.0 ."
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

                stage('Push image') {
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
                            catchError(buildResult: 'SUCCESS', stageResult: 'SUCCEDD') {
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
                            echo 'Building result microservice docker image for testing'
                            sh 'docker build -t ch03be_result:stable-1.0.0 . --target production --load .'
                            sh "docker tag ch03be_result:stable-1.0.0 hftamayo/ch03be_result:stable-1.0.0"
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
                                envsubst < k8s/micronode.yaml | kubectl apply -f -
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
                        echo 'Building frontend docker image for testing'
                        sh 'docker build -t ch03fe_vote:test --target dev --load .'
                    }
                }

                stage('Run frontend test microservice container') {
                    steps {
                        echo 'Running the frontend test microservice container'
                        script {
                            def result = sh(script: 'docker run -d -p 8080:80 --name frontend ch03fe_vote:test', returnStdout: true)
                            def containerId = result.trim()
                            env.FRONTEND_CONTAINER_ID = containerId
                        }
                    }
                    post {
                        failure {
                            echo 'Stopping the frontend microservice container due to a failure'
                            sh 'docker stop frontend'
                        }
                    }
                }

                stage('Run frontend testing routines') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            echo 'Running frontend microservice test routines'
                            sh "docker exec -it ${env.FRONTEND_CONTAINER_ID} python -m unittest discover -s tests -p 'test_*.py' -v"
                        }
                    }
                    post {
                        always {
                            echo 'Stopping the frontend microservice test container'
                            sh 'docker stop ${env.FRONTEND_CONTAINER_ID}'
                        }
                        failure {
                            echo 'No tests were found'
                        }
                    }
                }

                stage('Build image') {
                    steps {
                        echo 'Building the image'
                        sh 'docker build -t ch03fe_vote:stable-1.0.0 .'
                    }
                }

                stage('Push image') {
                    steps {
                        echo 'Pushing the image'
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
                                envsubst < k8s/frontend.yaml | kubectl apply -f -
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
