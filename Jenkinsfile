pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jenkins-demo'
        CONTAINER_NAME = 'jenkins-demo-app'
        TEST_CONTAINER_NAME = 'jenkins-demo-test'
    }

    stages {
        stage("1. Verification") {
            steps {
                sh '''
                    echo "Verification des fichiers presents..."
                    test -f index.html
                    test -f Dockerfile
                    test -f test.sh
                '''
            }
        }

        stage("2. Test unitaire") {
            steps {
                sh './test.sh'
            }
        }

        stage("3. Construction de l'image Docker") {
            steps {
                sh '''
                    echo "Construction de l'image avec le tag BUILD_NUMBER: ${BUILD_NUMBER}"
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage("4. Test du conteneur") {
            steps {
                sh '''
                    docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true

                    docker run -d --name ${TEST_CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}

                    sleep 3

                    docker exec ${TEST_CONTAINER_NAME} sh -c \
                        "wget -q -O - http://localhost | grep -q 'Application déployée par Jenkins'"
                '''
            }
        }

        stage("5. Deploiement") {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p 8081:80 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "Deploiement termine sur http://localhost:8081"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true'
        }

        success {
            echo "Pipeline termine avec succes"
        }

        failure {
            echo "Le pipeline a echoue, verifie la console"
        }
    }
}
