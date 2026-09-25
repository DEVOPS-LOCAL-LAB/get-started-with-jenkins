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
                    echo "🔍 Vérification des fichiers présents..."
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
                    echo "🔨 Construction de l'image avec le tag BUILD_NUMBER: ${BUILD_NUMBER}"
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage("4. Test du conteneur") {
            steps {
                sh '''
                    echo "🧹 Nettoyage d'un éventuel ancien conteneur de test..."
                    docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true

                    echo "▶️ Démarrage du conteneur de test..."
                    docker run -d --name ${TEST_CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "⏳ Attente de 3 secondes pour le démarrage de Nginx..."
                    sleep 3

                    echo "🔎 Vérification du contenu de la page directement dans le conteneur..."
                    # On utilise 'cat' au lieu de 'wget' car wget n'est pas installé dans nginx:alpine
                    docker exec ${TEST_CONTAINER_NAME} sh -c "cat /usr/share/nginx/html/index.html | grep -q 'Application déployée par Jenkins'"
                    
                    echo "✅ Le conteneur est valide et contient la bonne page !"
                '''
            }
        }

        stage("5. Deploiement") {
            steps {
                sh '''
                    echo "🧹 Nettoyage de l'ancienne version de l'application..."
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    echo "🚀 Déploiement de la nouvelle version sur le port 8081..."
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p 8081:80 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "🎉 Déploiement terminé ! Visible sur http://localhost:8081"
                '''
            }
        }
    }

    post {
        always {
            echo "🧽 Nettoyage final du conteneur de test (exécuté quoi qu'il arrive)..."
            sh 'docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true'
        }

        success {
            echo "🏆 Pipeline terminé avec SUCCÈS !"
        }

        failure {
            echo "❌ Le pipeline a échoué, vérifie la console."
        }
    }
}
