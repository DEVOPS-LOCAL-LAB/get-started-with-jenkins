pipeline {
    agent any
    
    parameters {
        string(name: 'APP_PORT', defaultValue: '8082', description: 'Port sur lequel deployer l application')
        string(name: 'APP_NAME', defaultValue: 'jenkins-demo-v2', description: 'Nom du container de deploiement')
    }

    environment {
        IMAGE_NAME = 'jenkins-demo'
        TEST_CONTAINER_NAME = 'jenkins-demo-test'
        
        // MAPPING : On crée des variables SANS POINT pour que le Shell les comprenne
        DEPLOY_APP_NAME = "${params.APP_NAME}"
        DEPLOY_APP_PORT = "${params.APP_PORT}"
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
                    docker exec ${TEST_CONTAINER_NAME} grep -q 'Application déployée par Jenkins' /usr/share/nginx/html/index.html
                '''
            }
        }

        stage('Deploiement') {
            steps {
                sh '''
                    # ATTENTION : On utilise DEPLOY_APP_NAME et DEPLOY_APP_PORT, PAS params.xxx
                    docker rm -f ${DEPLOY_APP_NAME} 2>/dev/null || true
                    docker run -d --name ${DEPLOY_APP_NAME} -p ${DEPLOY_APP_PORT}:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                    echo "Deploiement reussi sur le port ${DEPLOY_APP_PORT}"
                '''
            }
        }
        
        stage('Nettoyage') {
            steps {
                sh '''
                    echo "Suppression des anciennes images Docker non utilisees"
                    docker image prune -f
                    echo "Nettoyage termine"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true'
        }
        success {
            echo 'Pipeline termine avec succes'
        }
        failure {
            echo 'Le pipeline a echoue'
        }
    }
}
