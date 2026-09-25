pipeline {
    agent any
    
	// NOTION 1 : Parametres dynamiques
	parameters {
		string(name: 'APP_PORT', defaultValue: '8082', description: 'Port sur  laquel deployer  l application')
		string(name: 'APP_NAME', defaultValue: 'jenkins-demo-v2', description: "Nomdu container de deploiement")
	}

    environment {
        IMAGE_NAME = 'jenkins-demo'
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
					# Utilisation des variables params definies plus haut
                    docker rm -f ${params.APP_NAME} 2>/dev/null || true
                    docker run -d --name ${params.APP_NAME} -p ${params.APP_PORT}:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                    echo "Deploiement reussi sur le port ${params.APP_PORT}"
                '''
            }
        }
        
        // Notion 2 : Netoyage des ressources pour eviter la saturation du disque
        stage ('Netoyage') {
			steps {
				sh '''
					echo "Supression des anciennes  images Docker non utilisees"
					docker image prune -f
					echo "Netoyage termine"
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
