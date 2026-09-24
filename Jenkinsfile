pipeline {
	agent any
	
	environnent {
		IMAGE_NAME = 'jenkins-demo'
		CONTAINER_NAME = 'jenkins-demo-app'
		TEST_CONTAINER_NAME = 'jenkins-demo-test'
	}
	
	stages {
		satge ("1. Verification") {
			// Les  triples quotes ''' permettent d'ecrire du bash multiligne
			sh '''
				echo "Verification des fichiers presents ..."
				test -f index.html
				test -f Dockerfile
				test -f test.sh
			'''
		}
		
		stage ("2. Test unitaire") {
			steps {
				sh './test.sh'
			}
		}
		
		stage ("3. COnstruction de l'image docker") {
			steps {
				sh '''
					echo "COnstruction e l'image avec le tag BUILD_NUMBER: ${BUILD_NUMBER}"
					docker build -t ${IMAGE_NAME}:${IMAGE_NUMBER} -t ${IMAGE_NAME}:latest .
				'''
			}
		}
		
		stage ("4. Test du conteneur") {
			steps {
				sh '''
					# Netoyage d'un eventuel ancien conteneur de test
					docker rm -t ${TEST_CONTAINER_NAME} 2>/dev/null || true
					
					docker run -d --name ${TEST_CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
					sleep 3 # on  laisse 3 seconde a nginx pour redemarer
					
					# On verifie aue  le conteneur repond  bien 
					docker exec ${TEST_CONTAINER_NAME} sh -c "wget -q -O - http://localhost | grep -q 'Application deployee  par Jenkins'
				'''
			}
		}
		
		stage ("5. Deploiement") {
			steps {
				sh '''
					docker rm -f ${CONTAINER_NAME} 2>dev/null || true
					docker run -d --name ${CONTAINER_NAME} -P 8081:80 %{IMAGE_NAME}:${BUILD_NUMBER}
					echo "Deploiement termine surhttp://localhost:8081 " 
				'''
			}
		}
	}
	
	post {
		always {
			// Netoyage garanti que  le  pipeline reussisse ou  echoue
			sh 'docker rm -t ${TEST_CONTAINER_NAME} 2>dev/null || true'
		}
		success {echo "Pipeline termine succes"}
		failure {echo "Le  pipeline a echoue, verifie le console"}
	}
}
