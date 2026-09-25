pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jenkins-demo'
        CONTAINER_NAME = 'jenkins-demo-app'
        TEST_CONTAINER_NAME = 'jenkins-demo-test'
    }

    stages {
        stage('Verification') {
            steps {
                sh '''
                    test -f index.html
                    test -f Dockerfile
                    test -f test.sh
                '''
            }
        }

        stage('Test unitaire') {
            steps {
                sh './test.sh'
            }
        }

        stage('Construction de l image Docker') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Test du conteneur') {
            steps {
                sh '''
                    docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true
                    docker run -d --name ${TEST_CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
                    sleep 3
                    
                    # grep lit directement le fichier, ce qui évite les erreurs de pipe avec sh -c dans Jenkins
                    docker exec ${TEST_CONTAINER_NAME} grep -q 'Application déployée par Jenkins' /usr/share/nginx/html/index.html
                '''
            }
        }

        stage('Deploiement') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                    docker run -d --name ${CONTAINER_NAME} -p 8081:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true'
        }
        success {
            echo 'Pipeline terminé avec succès'
        }
        failure {
            echo 'Le pipeline a échoué'
        }
    }
}
